# App Icon für TimeCapsule

Für ein professionelles App-Icon benötigen Sie:

1. Ein 1024x1024 Pixel großes PNG-Bild
2. Ein transparentes oder weißes Hintergrundbild für das adaptive Icon (Android)

## Kostenlose Icon-Generatoren

Sie können eine der folgenden Seiten nutzen, um ein kostenloses App-Icon zu erstellen:

- [Canva](https://www.canva.com/create/app-icons/) - Bietet viele kostenlose Vorlagen
- [IconKitchen](https://icon.kitchen/) - Einfacher Online-Generator für App-Icons
- [AppIconMaker](https://appiconmaker.co/) - Erstellt Icons für alle Plattformen

## Empfohlenes Icon-Design für TimeCapsule

Ein gutes Icon für die TimeCapsule-App könnte enthalten:
- Eine Zeitkapsel oder Truhe
- Ein Uhrensymbol oder Sanduhr (für den Zeitaspekt)
- Fotos oder Erinnerungssymbole
- Blaue oder violette Farbtöne (wie bereits in der App verwendet)

## Icon-Dateien platzieren

1. Speichern Sie Ihr Haupticon als `app_icon.png` in diesem Ordner
2. Für adaptive Android-Icons:
   - Speichern Sie den Vordergrund als `app_icon_foreground.png` in diesem Ordner
   
## Icons anwenden

Nachdem Sie die Icons platziert haben, führen Sie folgenden Befehl aus:

```bash
flutter pub run flutter_launcher_icons
```

Dies wird automatisch die Icons für Android und iOS generieren und einfügen. 