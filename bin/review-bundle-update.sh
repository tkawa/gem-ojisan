#!/bin/bash
set -ev

# PROJECT=SonicGarden/repo_name
REPO_URL="https://github.com/${PROJECT}.git"
# BASE_BRANCH=staging

if [ -z "${PROJECT}" ]; then
  echo 'PROJECT env var required.'
  exit 1
fi

if [ -n "${GITHUB_ACCESS_TOKEN}" ]; then
  export GITHUB_TOKEN="${GITHUB_ACCESS_TOKEN}"
else
  echo 'GITHUB_ACCESS_TOKEN env var required.'
  exit 1
fi

# add gem executables to PATH
# https://qiita.com/paming/items/8276173c8d8c16ef79d9
GEM_EXE_DIR=$(gem env | grep "EXECUTABLE DIRECTORY" | awk '{print $4}')
export PATH=$PATH:$GEM_EXE_DIR

# install gem tools
gem install --no-document bundler_diffgems pull_request-create specific_install
gem specific_install tkawa/bundler-audit json-format
gem specific_install tkawa/ruby-restore_bundled_with

# install github_httpsable
if [ ! -x /tmp/github_httpsable ]; then
  curl -fSL https://github.com/packsaddle/rust-github_httpsable_cli/releases/download/v1.0.0/github_httpsable_cli-v1.0.0-x86_64-unknown-linux-musl.tar.gz \
    -o /tmp/github_httpsable_cli.tar.gz \
    && tar xzf /tmp/github_httpsable_cli.tar.gz -C /tmp \
    && chmod +x /tmp/github-httpsable
fi

mkdir -p /tmp/${PROJECT}_bundle_update
cd /tmp/${PROJECT}_bundle_update
/tmp/github-httpsable clone "${REPO_URL}" .
if [ -n "${BASE_BRANCH}" ]; then
  git fetch -f origin ${BASE_BRANCH}
  git checkout ${BASE_BRANCH}
fi

# git prepare
git config user.name sg-bot
git config user.email sg-bot@sonicgarden.jp
HEAD_DATE=$(date +%Y%m%dT%H%M%SZ)
HEAD="bundle/update-${HEAD_DATE}"

# checkout
git checkout -q -B "${HEAD}"

# bundle install
sed -i '' -e 's/^ruby /# ruby /' Gemfile
bundle --no-deployment --without nothing --jobs=4 --retry=3 --path vendor/bundle

# bundle audit
bundle audit update
AUDIT=$(bundle audit)

if [ -n "${CREATE_PULL_REQUEST}" ]; then
  # bundle update
  bundle update
  TABLE=$(bundle diffgems -f md_table)

  restore-bundled-with
  git add Gemfile.lock
  git commit -m "Bundle update ${HEAD_DATE}"

  # git push
  git push origin "${HEAD}"

  # pull request
  BODY="${AUDIT}
  ***
  ${TABLE}"
  pull-request-create create --title "Bundle update by gem-ojisan ${HEAD_DATE}" --body "${BODY}"
fi

exit 0
