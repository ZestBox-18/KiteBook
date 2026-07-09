import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';
import { Clog } from 'kite_utils';

const TAG: string = '[EntryBackupAbility]';

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup() {
    Clog.info(TAG, 'onBackup ok');
    await Promise.resolve();
  }

  async onRestore(bundleVersion: BundleVersion) {
    Clog.info(TAG, 'onRestore ok', bundleVersion);
    await Promise.resolve();
  }
}
