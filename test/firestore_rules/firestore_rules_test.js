/**
 * Türkiye Kan Ağı — Firestore Güvenlik Kuralları Emulator Testleri
 * Çalıştırma:
 *   firebase emulators:exec --only firestore "npm --prefix test/firestore_rules test"
 */
const { describe, it, before, after } = require('node:test');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const fs = require('fs');
const path = require('path');

const PROJECT_ID = 'demo-turkiye-kan-agi';

describe('Firestore Security Rules — users & blood_requests (KVKK & Karşılıklı Onay)', () => {
  let testEnv;

  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: fs.readFileSync(
          path.resolve(__dirname, '../../firestore.rules'),
          'utf8',
        ),
      },
    });
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  it('Kullanıcı kendi public profilini oluşturabilir, ancak içine kan grubu veya telefon yazamaz', async () => {
    const aliceDb = testEnv.authenticatedContext('alice').firestore();

    await assertSucceeds(
      aliceDb.collection('users').doc('alice').set({
        uid: 'alice',
        displayName: 'Ayşe Y.',
        useNickname: true,
        province: 'Ankara',
        district: 'Çankaya',
        isAvailableToDonate: true,
      }),
    );

    await assertFails(
      aliceDb.collection('users').doc('alice').set({
        uid: 'alice',
        displayName: 'Ayşe Y.',
        bloodType: 'A+',
      }),
    );
  });

  it('private_data alt koleksiyonunu SADECE sahibi okuyabilir', async () => {
    const aliceDb = testEnv.authenticatedContext('alice').firestore();
    const bobDb = testEnv.authenticatedContext('bob').firestore();

    await assertSucceeds(
      aliceDb
        .collection('users')
        .doc('alice')
        .collection('private_data')
        .doc('sensitive_profile')
        .set({
          fullName: 'Ayşe Yılmaz',
          bloodType: 'A+',
          weightKg: 62,
        }),
    );

    await assertFails(
      bobDb
        .collection('users')
        .doc('alice')
        .collection('private_data')
        .doc('sensitive_profile')
        .get(),
    );
  });

  it('Kan talebi public dokümanına contactPhone yazılamaz; private_contact sadece talep sahibine açıktır', async () => {
    const ownerDb = testEnv.authenticatedContext('owner1').firestore();
    const strangerDb = testEnv.authenticatedContext('stranger1').firestore();

    await assertFails(
      ownerDb.collection('blood_requests').doc('req1').set({
        id: 'req1',
        requesterUid: 'owner1',
        patientInitials: 'M.K.',
        contactPhone: '+905320000000',
      }),
    );

    await assertSucceeds(
      ownerDb.collection('blood_requests').doc('req1').set({
        id: 'req1',
        requesterUid: 'owner1',
        patientInitials: 'M.K.',
        bloodType: 'A+',
        productType: 'erythrocyte',
        status: 'open',
      }),
    );

    await assertSucceeds(
      ownerDb
        .collection('blood_requests')
        .doc('req1')
        .collection('private_contact')
        .doc('info')
        .set({
          contactName: 'M.K.',
          contactPhone: '+905320000000',
        }),
    );

    await assertFails(
      strangerDb
        .collection('blood_requests')
        .doc('req1')
        .collection('private_contact')
        .doc('info')
        .get(),
    );
  });

  it('mutual_contacts dokümanını yalnızca talep sahibi oluşturabilir ve sadece onaylı bağışçı okuyabilir', async () => {
    const ownerDb = testEnv.authenticatedContext('owner1').firestore();
    const donorDb = testEnv.authenticatedContext('donor1').firestore();
    const strangerDb = testEnv.authenticatedContext('stranger1').firestore();

    await assertSucceeds(
      ownerDb
        .collection('blood_requests')
        .doc('req1')
        .collection('mutual_contacts')
        .doc('donor1')
        .set({
          donorUid: 'donor1',
          donorPhone: '+905321112233',
          requesterPhone: '+905334445566',
        }),
    );

    await assertSucceeds(
      donorDb
        .collection('blood_requests')
        .doc('req1')
        .collection('mutual_contacts')
        .doc('donor1')
        .get(),
    );

    await assertFails(
      strangerDb
        .collection('blood_requests')
        .doc('req1')
        .collection('mutual_contacts')
        .doc('donor1')
        .get(),
    );
  });
});
