url="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-minirootfs-3.21.3-x86_64.tar.gz"

curl -L $url -o alpine.tar.gz
mkdir -p alpine
tar -xzf alpine.tar.gz -C alpine --strip-components=1
rm alpine.tar.gz

cp ./oobe.sh ./alpine/etc/
cp ./wsl-distribution.conf ./alpine/etc/
cp ./wsl.conf ./alpine/etc/
mkdir -p ./alpine/usr/lib/wsl
cp ./boinc.ico ./alpine/usr/lib/wsl/
cp ./terminal-profile.json ./alpine/usr/lib/wsl/

cd alpine
tar --numeric-owner --absolute-names -c  * | gzip --best > ../install.tar.gz
cd ..
rm -rf alpine
mv install.tar.gz boinc-buda-runner.wsl
