# kakaotalk-nix

A Nix derivation to package [KakaoTalk](https://www.kakaocorp.com/page/service/service/KakaoTalk) for Nix/NixOS via [Wine](https://www.winehq.org/). \
KakaoTalk is South Korea's dominant instant messaging platform and has no official Linux client.

> This derivation was submitted as a pull request to [nixpkgs](https://github.com/NixOS/nixpkgs/pull/436278/). Until it is merged, you can use it directly from this repository.

A version of this using the [`mkWindowsAppNoCC`](https://github.com/emmanuelrosa/erosanix/tree/master/pkgs/mkwindowsapp) community packaging helper is available on  the [mkwindowsapp](https://github.com/aanhlongg/kakaotalk-nix/tree/mkwindowsapp) branch.

---
 
## Usage
 
### With Flakes
 
Add this repository as an input in your `flake.nix`:
 
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    kakaotalk-nix = {
      url = "github:aanhlongg/kakaotalk-nix";
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
  };
 
  outputs = { nixpkgs, kakaotalk-nix, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            kakaotalk-nix.packages.${pkgs.system}.default
          ];
        })
      ];
    };
  };
}
```
 
### Without Flakes
 
Clone this repository and build with:
 
```bash
NIXPKGS_ALLOW_UNFREE=1 nix-build -E 'with import <nixpkgs> {}; callPackage ./kakaotalk.nix {}'
```
 
Or add it to your configuration by importing and calling the package:
 
```nix
{ pkgs, ... }:
let
  kakaotalk = pkgs.callPackage /path/to/kakaotalk.nix {};
in {
  environment.systemPackages = [ kakaotalk ];
}
```
 
## Workarounds
 
### First Login Fails with "Cannot Connect to KakaoTalk Server"
 
KakaoTalk's "Use improved connection method" setting (`use_new_loco_asio`) is enabled by default and will cause the following error when attempting to log in:
```
Cannot connect to KakaoTalk server.
This may have been caused by unstable user network or the use of KakaoTalk may have been blocked by a firewall.

If this error is repeated, please contact the Network Manager.
(Error Code: 70111, 50101, LB)
```
This flake will automatically disable this settings during the `installPhase`.
After having logged in successfully, subsequent login attempts will not be affected by this issue.
 
If you encounter this error despite the fix, you can disable the setting manually:
 
1. Open KakaoTalk -> Settings -> Advanced
2. Disable **"Use improved connection method"**
3. Restart KakaoTalk and log in
 
## License
 
The code in this repository is released under the [MIT License](LICENSE).  
KakaoTalk itself is proprietary software (see [Kakao's Terms of Service](https://www.kakao.com/policy/terms)).
