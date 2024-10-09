# Install Wally packages & embed exported types #

wally install
rojo sourcemap test.project.json --output sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/