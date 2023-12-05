pushd %~dp0

cd ../public_html
start http://localhost:8080
call npx http-server

popd
