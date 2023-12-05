pushd %~dp0

cd ..

call npx tailwindcss -i ./tailwind/index.css -o ./public_html/css/index.css --watch

popd
