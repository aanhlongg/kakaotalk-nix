{
  lib,
  mkWindowsAppNoCC,
  wine,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
}:

mkWindowsAppNoCC rec {
  inherit wine;

  pname = "kakaotalk";
  version = "26.2.0";

  src = fetchurl {
    url = "https://lk.kakaocdn.net/talkpc/talk/win32/x64/KakaoTalk_Setup.exe";
    hash = "sha256-Fl4DFg2aGtual/iAIZ2zYblzQIjSSNPAzqP1WxwhF/c=";
  };

  icon = fetchurl {
    name = "kakaotalk.png";
    url = "https://t1.kakaocdn.net/kakaocorp/kakaocorp/admin/service/453a624d017900001.png";
    hash = "sha256-1RTNnl3GN84RhvWLjud5RNdHUu88CwsSyfNrko8IqCs=";
  };

  dontUnpack = true;

  wineArch = "win64";
  enableMonoBootPrompt = false;

  fileMap = {
    "$HOME/.local/share/kakaotalk" = "drive_c/users/$USER/AppData/Local/Kakao/KakaoTalk";
  };

  winAppInstall = ''
    wine ${src} /S
  '';

  winAppPreRun = "";

  # disables the option use_new_loco_asio that breaks the first login
  winAppRun = ''
    CONFIG_FILE="$WINEPREFIX/drive_c/users/$USER/AppData/Local/Kakao/KakaoTalk/pref.ini"
    (
      for i in {1..30}; do
        if [ -f "$CONFIG_FILE" ]; then
          sed -i 's/use_new_loco_asio = .*/use_new_loco_asio = no/' "$CONFIG_FILE"
          if ! grep -q "use_new_loco_asio" "$CONFIG_FILE"; then
            echo "use_new_loco_asio = no" >> "$CONFIG_FILE"
          fi
          break
        fi
        sleep 1
      done
    ) &
    wine "$WINEPREFIX/drive_c/Program Files/Kakao/KakaoTalk/KakaoTalk.exe" "$ARGS"
  '';

  winAppPostRun = "";

  nativeBuildInputs = [ copyDesktopItems ];

  installPhase = ''
    runHook preInstall
    ln -s $out/bin/.launcher $out/bin/${pname}
    install -Dm644 ${icon} $out/share/icons/hicolor/256x256/apps/kakaotalk.png
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "KakaoTalk";
      exec = "kakaotalk";
      icon = "kakaotalk";
      desktopName = "KakaoTalk";
      comment = meta.description;
      categories = [
        "Network"
        "InstantMessaging"
      ];
      terminal = false;
    })
  ];

  meta = {
    description = "Instant Messaging App operated by Kakao Corporation in South Korea";
    homepage = "https://www.kakaocorp.com/page/service/service/KakaoTalk";
    maintainers = with lib.maintainers; [ aanhlongg ];
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "kakaotalk";
  };
}
