# PetCare

**Love Your Pets Every Day.**

Flutter app for tracking pet health, vaccines, feeding, grooming, and weight.

## Application ID

`com.petcaremng.petcare`

## Features

- Dashboard with pet list, avatar, age, weight, last care
- Pet profile (species, breed, fur color, gender, photo)
- Vaccine schedule with reminders
- Feeding log (meal time, food type, portion)
- Health journal (illness, medication, weight)
- Grooming schedule (bath, nail trim, haircut)
- Statistics with weight chart and care schedule
- In-app shop with stars (earn or buy via Google Play)
- Themes, backgrounds, skins, premium features

## IAP

Remote config: `https://api2.blwsmartware.net/N217.json`

Product prefix: `pcn_pack_1` … `pcn_pack_10`, `pcn_remove_ads`

## Build

```bash
flutter pub get
python3 tool/generate_logo.py
dart run flutter_launcher_icons
flutter build appbundle --release
```
