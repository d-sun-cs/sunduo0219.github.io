rm -rf public
rm -rf .deploy_git
echo -ne '\n' | ssh root@sundocker.online rm -rf /usr/local/nginx/www/blog/*
mkdir .deploy_git
cp -r source/.github .deploy_git/
npm run deploy
scp -r public/* root@sundocker.online:/usr/local/nginx/www/blog/
