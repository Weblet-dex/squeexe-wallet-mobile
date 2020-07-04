import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';


/*                       -----README-----
    Because of the issue that was uncovered here https://github.com/ca333/komodoDEX/issues/732
    TL;DR - mm2 refuses to launch alongside flutter_driver on the same run.
    Until this is fixed we have to run tests the following way:
    1. flutter run -t test_driver/app.dart
    2. flutter drive --target=test_driver/app.dart --use-existing-app=http://127.0.0.1:64543/N3XhhddWVME=/
    In order to test swaps and send/receive I used the following seeds as env variables:
    export RICK='offer venue embark tank eyebrow grape great era nothing top unveil pear'
    export MORTY='pear enforce exit dial spell draft chief lobster cabin refuse swift scan'
    or simply do: source source_me_for_test_seeds
    PIN: 0000
    password: '           a'; ---> (11 spaces + 'a')
*/

void main() {
  FlutterDriver driver;
  
  // Variables
  final Map<String, String> envVars = Platform.environment;
  var seed = ['a', 'b'];
  var mortysRickAddress = '';
  var ricksMortyAddress = '';
  var sendAmount = '0.1';
  var password = '           a';
  var postRefreshSeed = '';
  bool isAndroid = false;
  const int coolOffTime = 2;

  // Text
  final SerializableFinder titleWelcome = find.text('WELCOME');
  final SerializableFinder seedPhrase = find.byValueKey('seed-phrase');
  final SerializableFinder rickAdd = find.text('Morty (MORTY)');
  final SerializableFinder mortyAdd = find.text('Rick (RICK)');
  final SerializableFinder morty = find.text('MORTY');
  final SerializableFinder rick = find.text('RICK');
  final SerializableFinder bitcoin = find.text('BITCOIN');
  final SerializableFinder komodo = find.text('KOMODO');
  final SerializableFinder address = find.byValueKey('coin-details-address');
  final SerializableFinder successSend = find.text('Success!');
  final SerializableFinder whichWordText = find.byValueKey('which-word');
  final SerializableFinder connecting = find.text('Connecting...');
  final SerializableFinder loadingCoins = find.text('Loading coins');

  //Lists
  List<SerializableFinder> coinsOnActivationCheck = List<SerializableFinder>(4);


  // Buttons
  final SerializableFinder createWallet = find.text('CREATE A WALLET');
  final SerializableFinder restoreWallet = find.text('RESTORE');
  final SerializableFinder setup = find.text('LET\'S GET SET UP!');
  final SerializableFinder welcomeSetup = find.byValueKey('welcome-setup');
  final SerializableFinder seedRefresh = find.byValueKey('seed-refresh');
  final SerializableFinder seedCopy = find.byValueKey('seed-copy');
  final SerializableFinder next = find.text('NEXT');
  final SerializableFinder receive = find.text('RECEIVE');
  final SerializableFinder close = find.text('CLOSE');
  final SerializableFinder back = find.byTooltip('Back');
  final SerializableFinder switchTile = find.text('Activate PIN protection');
  final SerializableFinder switchPin = find.byValueKey('settings-activate-pin');
  final SerializableFinder logout = find.byValueKey('settings-logout');
  final SerializableFinder logoutYes = find.byValueKey('settings-logout-yes');
  final SerializableFinder logoutCancel = find.byValueKey('settings-logout-cancel');
  final SerializableFinder send = find.byValueKey('secondary-button-send');
  final SerializableFinder cancel = find.byValueKey('secondary-button-cancel');
  final SerializableFinder withdraw = find.byValueKey('primary-button-withdraw');
  final SerializableFinder confirm = find.byValueKey('primary-button-confirm');
  final SerializableFinder customFee = find.byValueKey('send-toggle-customfee');
  final SerializableFinder settings = find.byValueKey('nav-settings');
  final SerializableFinder portfolio = find.byValueKey('nav-portfolio');
  final SerializableFinder dex = find.byValueKey('nav-dex');
  final SerializableFinder markets = find.byValueKey('nav-markets');
  final SerializableFinder news = find.byValueKey('nav-news');
  final SerializableFinder login = find.text('LOGIN');
  final SerializableFinder pasteIOS = find.text('Paste');
  final SerializableFinder pasteAndroid = find.text('PASTE');
  final SerializableFinder continueSeedVerification = find.text('CONTINUE');
  final SerializableFinder confirmPassword = find.byValueKey('confirm-password');

  // Scrollables
  final SerializableFinder settingsScrollable = find.byValueKey('settings-scrollable');
  final SerializableFinder welcomeScrollable = find.byValueKey('welcome-scrollable');
  final SerializableFinder newAccountScrollable = find.byValueKey('new-account-scrollable');
  final SerializableFinder disclamerScrollable = find.byValueKey('scroll-disclaimer');
  final SerializableFinder portfolioCoinsScrollable = find.byValueKey('list-view-coins');
  

  // Input fields
  final SerializableFinder nameWalletField = find.byValueKey('name-wallet-field');
  final SerializableFinder enterPasswordField = find.byValueKey('enter-password-field');
  final SerializableFinder passwordCreate = find.byValueKey('create-password-field');
  final SerializableFinder passwordConfirm = find.byValueKey('create-password-field-confirm');
  final SerializableFinder amountField = find.byValueKey('send-amount-field');
  final SerializableFinder recipientsAddress = find.byValueKey('send-address-field');
  final SerializableFinder whichWordField = find.byValueKey('which-word-field');



  setUpAll(() async {
    driver = await FlutterDriver.connect();
    final String platform = await driver.requestData('platform');
    if (platform == 'android') isAndroid = true;
  });


  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
  });


  group('Driver Health |', () {
    test('-0- | Print flutter driver health', () async {
      final Health health = await driver.checkHealth();
      print(health.status);
    });
  });


  group('Create new wallet |', () {
    test('-1- | Create wallet name', () async {
      expect(await driver.getText(createWallet), 'CREATE A WALLET');
      expect(await driver.getText(restoreWallet), 'RESTORE');
      await driver.waitFor(createWallet);
      await driver.tap(createWallet);
      expect(await driver.getText(titleWelcome), 'WELCOME');
      await driver.waitFor(nameWalletField);
      await driver.tap(nameWalletField);
      await driver.enterText('testNewWallet');
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);
    });


    test('-2- | Check seed refresh', () async {
      var initialSeed = '';
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(seedPhrase);
      await driver.getText(seedPhrase).then((val) {
        initialSeed = val;
      });
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(seedCopy);
      await driver.tap(seedRefresh);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.getText(seedPhrase).then((val) {
        postRefreshSeed = val;
      });
      if (initialSeed == postRefreshSeed){
        await driver.waitFor(find.text('NONE EXISTENT TEXT TO FAIL THE TEST'),
                              timeout: const Duration(seconds: 1));
      }
    });


    test('-3- | Check if seed copy works', () async {
      final pasteFinder = isAndroid ? pasteAndroid : pasteIOS;

      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(seedCopy);
      await driver.tap(seedCopy);
      await driver.scrollUntilVisible(newAccountScrollable, next, dyScroll: -300);
      await driver.waitFor(next);
      await driver.tap(next); 
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(whichWordField);
      await driver.tap(whichWordField);
      await driver.scroll(whichWordField, 0, 0, const Duration(milliseconds: 1100));
      await driver.waitFor(pasteFinder);
      await driver.tap(pasteFinder);
      await driver.waitFor(back);
      await driver.tap(back);
    });
    

    test('-4- | Save seed', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(seedPhrase);
      await driver.getText(seedPhrase).then((val) {
        seed = val.split(' ');
      });
    });


    test('-5- | Verify seed', () async {
      int whichWord;
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.scrollUntilVisible(newAccountScrollable, next, dyScroll: -300);
      await driver.waitFor(next);
      await driver.tap(next);
      for (int i = 0; i <= 2; i++){
        await driver.waitFor(whichWordText);
        await driver.getText(whichWordText).then((val) {
          whichWord = int.tryParse(val.split(' ')[3].replaceAll(RegExp(r'[^\w\s]+'),''))  - 1;
        });
        await driver.waitFor(whichWordField);
        await driver.tap(whichWordField);
        await driver.enterText(seed[whichWord]);
        await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
        await driver.scrollIntoView(continueSeedVerification);
        await driver.waitFor(continueSeedVerification);
        await driver.tap(continueSeedVerification);
      }
    });
    

    test('-6- | Create password', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      expect(await driver.getText(find.text('CREATE A PASSWORD')), 'CREATE A PASSWORD');
      await driver.waitFor(passwordCreate);
      await driver.tap(passwordCreate);
      await driver.enterText(password);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(passwordConfirm);
      await driver.tap(passwordConfirm);
      await driver.enterText(password);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(find.text('CONFIRM PASSWORD'));
      await driver.tap(find.text('CONFIRM PASSWORD'));
    });


    test('-7- | Validate disclaimer', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.scrollUntilVisible(disclamerScrollable,
          find.byValueKey('end-list-disclaimer'),
          dyScroll: -5000);
      await driver.tap(find.byValueKey('checkbox-eula'));
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.tap(find.byValueKey('checkbox-toc'));
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.tap(find.byValueKey('next-disclaimer'));
    });


    test('-8- | Create PIN', () async {
      await driver.waitFor(find.text('Create PIN'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
      await driver.waitFor(find.text('Confirm PIN code'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });


    test('-9- | Check if mm2 successfully connected', () async {
      await Future<void>.delayed(const Duration(milliseconds: 5000), () {});
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    });


    test('-10- | Logout from new wallet with cancel check.', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(settings);
      await driver.tap(settings);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(logout);
      await driver.tap(logout);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(logoutCancel);
      await driver.tap(logoutCancel);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(logout);
      await driver.tap(logout);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(logoutYes);
      await driver.tap(logoutYes);
    });
  });

  //RELOG #1
  group('Test send/receive |', () {
    test('-11- | Restore morty wallet (Delay: $coolOffTime min) - Lets let mm2 to cool off a bit', () async {
      await Future<void>.delayed(const Duration(minutes: coolOffTime), () {});
      expect(await driver.getText(createWallet), 'CREATE A WALLET');
      expect(await driver.getText(restoreWallet), 'RESTORE');
      await driver.waitFor(restoreWallet);
      await driver.tap(restoreWallet);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      expect(await driver.getText(titleWelcome), 'WELCOME');
      await driver.waitFor(nameWalletField);
      await driver.tap(nameWalletField);
      await driver.enterText('MORTY');
      await driver.waitFor(find.text('MORTY'));
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);
    }, timeout: const Timeout(Duration(minutes: coolOffTime + 1)));
    

    test('-12- | Enter MORTY seed', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(find.byValueKey('restore-seed-field'));
      await driver.tap(find.byValueKey('restore-seed-field'));
      await driver.enterText(envVars['MORTY']);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(find.byValueKey('confirm-seed-button'));
      await driver.tap(find.byValueKey('confirm-seed-button'));
    });


    test('-13- | Create MORTY password', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      expect(await driver.getText(find.text('CREATE A PASSWORD')),'CREATE A PASSWORD');
      await driver.waitFor(passwordCreate);
      await driver.tap(passwordCreate);
      await driver.enterText(password);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(passwordConfirm);
      await driver.tap(passwordConfirm);
      await driver.enterText(password);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(find.text('CONFIRM PASSWORD'));
      await driver.tap(find.text('CONFIRM PASSWORD'));
    });


    test('-14- | Validate MORTY disclaimer', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.scrollUntilVisible(find.byValueKey('scroll-disclaimer'),
          find.byValueKey('end-list-disclaimer'),
          dyScroll: -3500);
      await driver.tap(find.byValueKey('checkbox-eula'));
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.tap(find.byValueKey('checkbox-toc'));
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.tap(find.byValueKey('next-disclaimer'));
    });


    test('-15- | Create MORTY PIN ', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(find.text('Create PIN'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(find.text('Confirm PIN code'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });


    test('-16- | Check if mm2 successfully connected', () async {
      await Future<void>.delayed(const Duration(milliseconds: 5000), () {});
      await driver.waitFor(bitcoin);
      await driver.waitFor(komodo);
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    });


    test('-17- | Activate rick and morty coins', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(find.byValueKey('adding-coins'));
      await driver.tap(find.byValueKey('adding-coins'));
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.scrollIntoView(mortyAdd);
      await driver.waitFor(mortyAdd);
      await driver.tap(mortyAdd);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.scrollIntoView(rickAdd);
      await driver.waitFor(rickAdd);
      await driver.tap(rickAdd);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(find.byValueKey('done-activate-coins'));
      await driver.tap(find.byValueKey('done-activate-coins'));
      await driver.waitForAbsent(loadingCoins);
    });


    
    test('-18- | Get mortysRickAddress', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.scrollIntoView(rick);
      await driver.waitFor(rick);
      await driver.tap(rick);
      await Future<void>.delayed(const Duration(milliseconds: 3000), () {});
      await driver.runUnsynchronized(() async {
      await driver.waitFor(receive);
      await driver.tap(receive);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(address);
      await driver.getText(address).then((val) {
        mortysRickAddress = val;
      });
      await driver.waitFor(close);
      await driver.tap(close);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(back);
      await driver.tap(back);
    });});


    test('-19- | Logout from MORTY wallet', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(settings);
      await driver.tap(settings);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(logout);
      await driver.tap(logout);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(logoutYes);
      await driver.tap(logoutYes);
    });

    //RELOG-2
    test('-20- | Restore RICK wallet (Delay: $coolOffTime min) - Lets let mm2 to cool off a bit', () async {
      await Future<void>.delayed(const Duration(minutes: coolOffTime), () {});
      expect(await driver.getText(createWallet), 'CREATE A WALLET');
      expect(await driver.getText(restoreWallet), 'RESTORE');
      await driver.waitFor(restoreWallet);
      await driver.tap(restoreWallet);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      expect(await driver.getText(titleWelcome), 'WELCOME');
      await driver.waitFor(nameWalletField);
      await driver.tap(nameWalletField);
      await driver.enterText('RICK');
      await driver.waitFor(find.text('RICK'));
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);
    }, timeout: const Timeout(Duration(minutes: coolOffTime + 1)));
    

    test('-21- | Restore rick seed', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(find.byValueKey('restore-seed-field'));
      await driver.tap(find.byValueKey('restore-seed-field'));
      await driver.enterText(envVars['RICK']);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(find.byValueKey('confirm-seed-button'));
      await driver.tap(find.byValueKey('confirm-seed-button'));
    });


    test('-22- | Create RICK password', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      expect(await driver.getText(find.text('CREATE A PASSWORD')), 'CREATE A PASSWORD');
      await driver.waitFor(passwordCreate);
      await driver.tap(passwordCreate);
      await driver.enterText(password);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(passwordConfirm);
      await driver.tap(passwordConfirm);
      await driver.enterText(password);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(find.text('CONFIRM PASSWORD'));
      await driver.tap(find.text('CONFIRM PASSWORD'));
    });


    test('-23- | Validate rick disclaimer', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(find.text('Disclaimer & ToS'));
      await driver.scrollUntilVisible(find.byValueKey('scroll-disclaimer'),
          find.byValueKey('end-list-disclaimer'),
          dyScroll: -5000);
      await driver.waitFor(find.byValueKey('checkbox-eula'));
      await driver.tap(find.byValueKey('checkbox-eula'));
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(find.byValueKey('checkbox-toc'));
      await driver.tap(find.byValueKey('checkbox-toc'));
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(find.byValueKey('next-disclaimer'));
      await driver.tap(find.byValueKey('next-disclaimer'));
    });


    test('-24- | Create rick PIN ', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(find.text('Create PIN'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(find.text('Confirm PIN code'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });


    test('-25- | Check if mm2 successfully connected', () async {
      await Future<void>.delayed(const Duration(milliseconds: 5000), () {});
      await driver.waitFor(rick);
      await driver.waitFor(morty);
      expect(await driver.getText(morty), 'MORTY');
      expect(await driver.getText(rick), 'RICK');
    });


    test('-26- | Get ricksMortyAddress', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.scrollIntoView(morty);
      await driver.waitFor(morty);
      await driver.tap(morty);
      await Future<void>.delayed(const Duration(milliseconds: 3000), () {});
      await driver.runUnsynchronized(() async {
      await driver.waitFor(receive);
      await driver.tap(receive);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(address);
      await driver.getText(address).then((val) {
        ricksMortyAddress = val;
      });
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(close);
      await driver.tap(close);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(back);
      await driver.tap(back);
    });});
    

    test('-27- | Send RICK from rick to morty', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(rick);
      await driver.tap(rick);
      print('from rick $ricksMortyAddress to morty $mortysRickAddress');
      await Future<void>.delayed(const Duration(milliseconds: 3000), () {});
      await driver.runUnsynchronized(() async {
      await driver.waitFor(send);
      await driver.tap(send);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(amountField);
      await driver.tap(amountField);
      await driver.enterText(sendAmount);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(recipientsAddress);
      await driver.tap(recipientsAddress);
      await driver.enterText(mortysRickAddress);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(withdraw);
      await driver.tap(withdraw);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(confirm);
      await driver.tap(confirm);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(successSend);
      await driver.waitForAbsent(successSend);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(back);
      await driver.tap(back);
    });},timeout: const Timeout(Duration(minutes: 2)));


    test('-28- | Logout from RICK wallet', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(settings);
      await driver.tap(settings);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(logout);
      await driver.tap(logout);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(logoutYes);
      await driver.tap(logoutYes);
    });
    

    // TODO(dth): figure out tests failing even though they pass.
    //RELOG-3
    test('-29- | Delay: $coolOffTime min - Let mm2 cool off a bit', () async {
      await driver.scrollIntoView(morty);
      await driver.scrollIntoView(rick);
      await driver.scrollIntoView(morty);
      await Future<void>.delayed(const Duration(minutes: coolOffTime), () {});
      await driver.scrollIntoView(rick);
      await driver.scrollIntoView(morty);
      await driver.scrollIntoView(rick);
    },timeout: const Timeout(Duration(minutes: coolOffTime + 1)));


    test('-30- | Login to MORTY wallet', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.tap(morty);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.tap(enterPasswordField);
      await driver.enterText(password);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.scrollIntoView(login);
      await driver.tap(login);
    });

    /* for PIN protection
    test('-31- | Enter PIN for MORTY wallet', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });
    */

    test('-32- | Check if mm2 successfully connected', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(rick);
      await driver.waitFor(morty);
      expect(await driver.getText(morty), 'MORTY');
      expect(await driver.getText(rick), 'RICK');
    });


    test('-33- | Check RICK transfer confirmed', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.tap(rick);
      await Future<void>.delayed(const Duration(milliseconds: 3000), () {});
      await driver.runUnsynchronized(() async {
      await driver.waitFor(find.text('+$sendAmount RICK'));
      await driver.waitFor(back);
      await driver.tap(back);
    });});


    test('-34- | Send MORTY from morty to rick', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.tap(morty);
      print('from morty $mortysRickAddress to rick $ricksMortyAddress'); // TODO(dth): proper logging
      await Future<void>.delayed(const Duration(milliseconds: 3000), () {});
      await driver.runUnsynchronized(() async {
      await driver.waitFor(send);
      await driver.tap(send);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(amountField);
      await driver.tap(amountField);
      await driver.enterText(sendAmount);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(recipientsAddress);
      await driver.tap(recipientsAddress);
      await driver.enterText(ricksMortyAddress);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(withdraw);
      await driver.tap(withdraw);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(confirm);
      await driver.tap(confirm);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(successSend);
      await driver.waitForAbsent(successSend);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(back);
      await driver.tap(back);
    });},timeout: const Timeout(Duration(minutes: 2)));


    test('-35- | LOGOUT from MORTY wallet', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(settings);
      await driver.tap(settings);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(logout);
      await driver.tap(logout);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(logoutYes);
      await driver.tap(logoutYes);
    });

    // TODO(dth): figure out tests failing even though they pass.
    //RELOG-4
    test('-36- | Delay: $coolOffTime min - Let mm2 cool off a bit', () async {
      await driver.scrollIntoView(morty);
      await driver.scrollIntoView(rick);
      await driver.scrollIntoView(morty);
      await Future<void>.delayed(const Duration(minutes: coolOffTime), () {});
      await driver.scrollIntoView(rick);
      await driver.scrollIntoView(morty);
      await driver.scrollIntoView(rick);
    },timeout: const Timeout(Duration(minutes: coolOffTime + 1)));


    test('-37- | LOGIN to RICK wallet ', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.tap(rick);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.tap(enterPasswordField);
      await driver.enterText(password);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.scrollIntoView(login);
      await driver.tap(login);
    });

    /* for PIN protection
    test('-38- | Enter PIN for RICK wallet', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });
    */
    test('-39- | Check if mm2 successfully connected', () async {
      await Future<void>.delayed(const Duration(milliseconds: 5000), () {});
      await driver.waitFor(rick);
      await driver.waitFor(morty);
      expect(await driver.getText(morty), 'MORTY');
      expect(await driver.getText(rick), 'RICK');
    });


    test('-40- | Check transfer from MORTY confirmed', () async {
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.scrollIntoView(morty);
      await driver.tap(morty);
      await Future<void>.delayed(const Duration(milliseconds: 3000), () {});
      await driver.runUnsynchronized(() async {
      await driver.waitFor(find.text('+$sendAmount MORTY'));
      await Future<void>.delayed(const Duration(milliseconds: 5000), () {});
      await driver.waitFor(back);
      await driver.tap(back);
    });});
  });


  group('Make Swaps |', (){
    test('-41- | Swap MORTY for RICK', () async{
      await driver.waitFor(dex);
      await driver.tap(dex);
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(find.byValueKey('coin-select-market.sell'));
      await driver.tap(find.byValueKey('coin-select-market.sell'));
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.scrollIntoView(find.byValueKey('item-dialog-morty-market.sell'));
      await driver.waitFor(find.byValueKey('item-dialog-morty-market.sell'));
      await driver.tap(find.byValueKey('item-dialog-morty-market.sell'));
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.scrollIntoView(find.byValueKey('input-text-market.sell'));
      await driver.waitFor(find.byValueKey('input-text-market.sell'));
      await driver.tap(find.byValueKey('input-text-market.sell'));
      await driver.enterText('1');
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(find.byValueKey('coin-select-market.receive'));
      await driver.tap(find.byValueKey('coin-select-market.receive'));
      await driver.scrollIntoView(find.byValueKey('orderbook-item-rick'));
      await driver.waitFor(find.byValueKey('orderbook-item-rick'));
      await driver.waitFor(find.byValueKey('orderbook-item-rick'));
      await driver.tap(find.byValueKey('orderbook-item-rick'));
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.scrollIntoView(find.byValueKey('ask-item-0'));
      await driver.waitFor(find.byValueKey('ask-item-0'));
      await driver.tap(find.byValueKey('ask-item-0'));
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.scrollIntoView(find.byValueKey('trade-button'));
      await driver.waitFor(find.byValueKey('trade-button'));
      await driver.tap(find.byValueKey('trade-button'));
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(find.byValueKey('swap-detail-title'));
      await driver.scrollIntoView(find.byValueKey('confirm-swap-button'));
      await driver.waitFor(find.byValueKey('confirm-swap-button'));
      await driver.tap(find.byValueKey('confirm-swap-button'));
      await Future<void>.delayed(const Duration(milliseconds: 2000), () {});
      await driver.waitFor(find.text('Order matched'));
      await driver.waitFor(find.text('Swap successful'));
      await driver.tap(find.byValueKey('swap-detail-back-button'));
    }, timeout: Timeout.none);
  });
  
  group('Settings |', () {
    test('-42- | Send feedback', () async {
      await driver.tap(settings);
      await driver.scrollUntilVisible(settingsScrollable,
          find.byValueKey('setting-title-feedback'),
          dyScroll: -300);
      await driver.tap(find.byValueKey('setting-title-feedback'));
      await driver.tap(find.byValueKey('setting-share-button'));
    });
  });
    

 
/*
  group('Restore wallet', () {
    test('Name Wallet', () async {
      final SerializableFinder createWallet = find.text('CREATE A WALLET');
      final SerializableFinder restoreWallet = find.text('RESTORE');
      final SerializableFinder titleWelcome = find.text('WELCOME');
      expect(await driver.getText(createWallet), 'CREATE A WALLET');
      expect(await driver.getText(restoreWallet), 'RESTORE');
      await driver.tap(restoreWallet);
      expect(await driver.getText(titleWelcome), 'WELCOME');
      final SerializableFinder nameWalletField =
          find.byValueKey('name-wallet-field');
      await driver.tap(nameWalletField);
      await driver.enterText('Mon super wallet');
      await driver.waitFor(find.text('Mon super wallet'));
      await driver.tap(setup);
    });
    test('Restore seed', () async {
      await driver.tap(find.byValueKey('restore-seed-field'));
      await driver.enterText(envVars['SEED']);
      await driver.tap(find.byValueKey('checkbox-custom-seed'));
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.byValueKey('confirm-seed-button'));
    });
    test('Create password', () async {
      expect(await driver.getText(find.text('CREATE A PASSWORD')),
          'CREATE A PASSWORD');
      await driver.tap(find.byValueKey('create-password-field'));
      await driver.enterText('Qwertyuiopas-');
      await driver.waitFor(find.text('Qwertyuiopas-'));
      await driver.tap(find.byValueKey('create-password-field-confirm'));
      await driver.enterText('Qwertyuiopas-');
      await driver.waitFor(find.text('Qwertyuiopas-'));
      await driver.tap(find.text('CONFIRM PASSWORD'));
    });
    test('Validate disclaimer', () async {
      await driver.waitFor(find.text('Disclaimer & ToS'));
      await driver.scrollUntilVisible(find.byValueKey('scroll-disclaimer'),
          find.byValueKey('end-list-disclaimer'),
          dyScroll: -5000);
      await driver.tap(find.byValueKey('checkbox-eula'));
      await driver.tap(find.byValueKey('checkbox-toc'));
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.byValueKey('next-disclaimer'));
    });
    test('Create PIN', () async {
      await driver.waitFor(find.text('Create PIN'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
      await driver.waitFor(find.text('Confirm PIN code'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });
    test('Check if default coins are here', () async {
      await driver.waitFor(find.text('KOMODO'));
      await driver.waitFor(find.text('BITCOIN'));
    });
  });
  group('Activate coins |', () {
    test('Activates all coins', () async {
      await driver.tap(find.byValueKey('adding-coins'));
      final SerializableFinder SelectUTXO = find.text('Select all UTXO coins');
      final SerializableFinder SelectSmartchains = find.text('Select all SmartChains');
      final SerializableFinder SelectERC = find.text('Select all ERC tokens');
      await driver.tap(SelectUTXO);
      await driver.scrollIntoView(SelectSmartchains);
      await driver.tap(SelectSmartchains);
      await driver.scrollIntoView(SelectERC);
      await driver.tap(SelectERC);
      await driver.tap(find.byValueKey('done-activate-coins'));
    });
  });
  //deactivated until we find a better way to deal with swap-tests
  
*/
}
