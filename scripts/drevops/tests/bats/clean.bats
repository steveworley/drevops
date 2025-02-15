#!/usr/bin/env bats
#
# Test for clean functionality.
#
# shellcheck disable=SC2030,SC2031,SC2129

load _helper
load _helper_drevops

@test "Clean" {
  run_install_quiet

  assert_files_present
  assert_git_repo

  mktouch "docroot/core/install.php"
  mktouch "docroot/modules/contrib/somemodule/somemodule.info.yml"
  mktouch "docroot/themes/contrib/sometheme/sometheme.info.yml"
  mktouch "docroot/profiles/contrib/someprofile/someprofile.info.yml"
  mktouch "docroot/sites/default/somesettingsfile.php"
  mktouch "docroot/sites/default/settings.generated.php"
  mktouch "docroot/sites/default/files/somepublicfile.php"

  mktouch "vendor/somevendor/somepackage/somepackage.php"
  mktouch "vendor/somevendor/somepackage/somepackage with spaces.php"
  mktouch "vendor/somevendor/somepackage/composer.json"
  # Make sure that sub-repos removed.
  mktouch "vendor/othervendor/otherpackage/.git/HEAD"

  mktouch "docroot/themes/custom/zzzsomecustomtheme/node_modules/somevendor/somepackage/somepackage.js"
  mktouch "docroot/themes/custom/zzzsomecustomtheme/node_modules/somevendor/somepackage/somepackage with spaces.js"

  mktouch "docroot/themes/custom/zzzsomecustomtheme/build/js/zzzsomecustomtheme.min.js"
  mktouch "docroot/themes/custom/zzzsomecustomtheme/build/css/zzzsomecustomtheme.min.css"
  mktouch "docroot/themes/custom/zzzsomecustomtheme/scss/_components.scss"

  mktouch "tests/behat/screenshots/s1.jpg"
  mktouch "tests/behat/screenshots/s2.jpg"

  mktouch ".data/db.sql"
  mktouch ".data/db_2.sql"

  mktouch "docroot/sites/default/settings.local.php"
  mktouch "docroot/sites/default/services.local.yml"

  echo "version: \"2.3\"" > "docker-compose.override.yml"

  mktouch ".idea/some_ide_file"
  mktouch ".vscode/some_ide_file"
  mktouch "nbproject/some_ide_file"

  mktouch "uncommitted_file.txt"

  ahoy clean

  assert_files_present
  assert_git_repo

  assert_dir_not_exists "docroot/core"
  assert_dir_not_exists "docroot/modules/contrib"
  assert_dir_not_exists "docroot/themes/contrib"
  assert_dir_not_exists "docroot/profiles/contrib"

  assert_file_exists "docroot/sites/default/somesettingsfile.php"
  assert_file_not_exists "docroot/sites/default/settings.generated.php"
  assert_file_exists "docroot/sites/default/files/somepublicfile.php"

  assert_dir_not_exists "vendor"
  assert_dir_not_exists "docroot/themes/custom/star_wars/node_modules"

  assert_dir_not_exists "docroot/themes/custom/star_wars/build"
  assert_file_not_exists "docroot/themes/custom/star_wars/scss/_components.scss"

  assert_file_exists "tests/behat/screenshots/s1.jpg"
  assert_file_exists "tests/behat/screenshots/s2.jpg"

  assert_file_exists ".data/db.sql"
  assert_file_exists ".data/db_2.sql"

  assert_file_exists "docroot/sites/default/settings.local.php"
  assert_file_exists "docroot/sites/default/services.local.yml"

  assert_file_exists "docker-compose.override.yml"

  assert_file_exists ".idea/some_ide_file"
  assert_file_exists ".vscode/some_ide_file"
  assert_file_exists "nbproject/some_ide_file"

  assert_file_exists "uncommitted_file.txt"
}

@test "Reset; no commit" {
  run_install_quiet

  assert_files_present
  assert_git_repo

  mktouch "first.txt"
  git_add "first.txt"
  git_commit "first commit"

  mktouch "docroot/core/install.php"
  mktouch "docroot/modules/contrib/somemodule/somemodule.info.yml"
  mktouch "docroot/themes/contrib/sometheme/sometheme.info.yml"
  mktouch "docroot/profiles/contrib/someprofile/someprofile.info.yml"
  mktouch "docroot/sites/default/somesettingsfile.php"
  mktouch "docroot/sites/default/settings.generated.php"
  mktouch "docroot/sites/default/files/somepublicfile.php"

  mktouch "vendor/somevendor/somepackage/somepackage.php"
  mktouch "vendor/somevendor/somepackage/somepackage with spaces.php"
  mktouch "vendor/somevendor/somepackage/composer.json"
  # Make sure that sub-repos removed.
  mktouch "vendor/othervendor/otherpackage/.git/HEAD"

  mktouch "docroot/themes/custom/zzzsomecustomtheme/node_modules/somevendor/somepackage/somepackage.js"
  mktouch "docroot/themes/custom/zzzsomecustomtheme/node_modules/somevendor/somepackage/somepackage with spaces.js"
  mktouch "docroot/themes/custom/zzzsomecustomtheme/scss/_components.scss"

  mktouch "docroot/themes/custom/zzzsomecustomtheme/build/js/zzzsomecustomtheme.min.js"
  mktouch "docroot/themes/custom/zzzsomecustomtheme/build/css/zzzsomecustomtheme.min.css"

  mktouch "tests/behat/screenshots/s1.jpg"
  mktouch "tests/behat/screenshots/s2.jpg"

  mktouch ".data/db.sql"
  mktouch ".data/db_2.sql"

  mktouch "docroot/sites/default/settings.local.php"
  mktouch "docroot/sites/default/services.local.yml"

  echo "version: \"2.3\"" > "docker-compose.override.yml"

  mktouch ".idea/some_ide_file"
  mktouch ".vscode/some_ide_file"
  mktouch "nbproject/some_ide_file"

  mktouch "uncommitted_file.txt"

  mktouch "composer.lock"
  mktouch "docroot/themes/custom/zzzsomecustomtheme/package-lock.json"

  ahoy reset

  assert_git_repo
  assert_files_not_present_common

  assert_dir_not_exists "docroot/core"
  assert_dir_not_exists "docroot/modules/contrib"
  assert_dir_not_exists "docroot/themes/contrib"
  assert_dir_not_exists "docroot/profiles/contrib"

  assert_file_not_exists "docroot/sites/default/somesettingsfile.php"
  assert_file_not_exists "docroot/sites/default/settings.generated.php"
  assert_file_not_exists "docroot/sites/default/files/somepublicfile.php"

  assert_dir_not_exists "vendor"
  assert_dir_not_exists "docroot/themes/custom/zzzsomecustomtheme/node_modules"

  assert_dir_not_exists "docroot/themes/custom/zzzsomecustomtheme/build"
  assert_file_not_exists "docroot/themes/custom/zzzsomecustomtheme/scss/_components.scss"

  assert_dir_not_exists "tests/behat/screenshots"

  assert_file_not_exists ".data/db.sql"
  assert_file_not_exists ".data/db_2.sql"

  assert_file_not_exists "docroot/sites/default/settings.local.php"
  assert_file_not_exists "docroot/sites/default/services.local.yml"

  assert_file_not_exists "docker-compose.override.yml"

  assert_file_exists ".idea/some_ide_file"
  assert_file_exists ".vscode/some_ide_file"
  assert_file_exists "nbproject/some_ide_file"

  assert_file_not_exists "uncommitted_file.txt"

  assert_file_not_exists "composer.lock"
  assert_file_not_exists "docroot/themes/custom/star_wars/package-lock.json"
}

@test "Reset; committed files" {
  run_install_quiet

  assert_files_present
  assert_git_repo

  mktouch "docroot/core/install.php"
  mktouch "docroot/modules/contrib/somemodule/somemodule.info.yml"
  mktouch "docroot/themes/contrib/sometheme/sometheme.info.yml"
  mktouch "docroot/profiles/contrib/someprofile/someprofile.info.yml"
  mktouch "docroot/sites/default/somesettingsfile.php"
  mktouch "docroot/sites/default/settings.generated.php"
  mktouch "docroot/sites/default/files/somepublicfile.php"

  mktouch "vendor/somevendor/somepackage/somepackage.php"
  mktouch "vendor/somevendor/somepackage/somepackage with spaces.php"
  mktouch "vendor/somevendor/somepackage/composer.json"
  # Make sure that sub-repos removed.
  mktouch "vendor/othervendor/otherpackage/.git/HEAD"

  mktouch "docroot/themes/custom/zzzsomecustomtheme/node_modules/somevendor/somepackage/somepackage.js"
  mktouch "docroot/themes/custom/zzzsomecustomtheme/node_modules/somevendor/somepackage/somepackage with spaces.js"

  mktouch "docroot/themes/custom/zzzsomecustomtheme/build/js/zzzsomecustomtheme.min.js"
  mktouch "docroot/themes/custom/zzzsomecustomtheme/build/css/zzzsomecustomtheme.min.css"
  mktouch "docroot/themes/custom/zzzsomecustomtheme/scss/_components.scss"

  mktouch "tests/behat/screenshots/s1.jpg"
  mktouch "tests/behat/screenshots/s2.jpg"

  mktouch ".data/db.sql"
  mktouch ".data/db_2.sql"

  mktouch "docroot/sites/default/settings.local.php"
  mktouch "docroot/sites/default/services.local.yml"

  echo "version: \"2.3\"" > "docker-compose.override.yml"

  mktouch ".idea/some_ide_file"
  mktouch ".vscode/some_ide_file"
  mktouch "nbproject/some_ide_file"

  mktouch "composer.lock"
  mktouch "docroot/themes/custom/star_wars/package-lock.json"

  git_add_all_commit "Added DrevOps files"

  mktouch "uncommitted_file.txt"

  # Commit other file file.
  mktouch "committed_file.txt"
  git add "committed_file.txt"
  git commit -m "Added custom file" > /dev/null

  ahoy reset

  assert_files_present_common
  assert_git_repo

  assert_dir_not_exists "docroot/core"
  assert_dir_not_exists "docroot/modules/contrib"
  assert_dir_not_exists "docroot/themes/contrib"
  assert_dir_not_exists "docroot/profiles/contrib"

  assert_file_not_exists "docroot/sites/default/somesettingsfile.php"
  assert_file_not_exists "docroot/sites/default/settings.generated.php"
  assert_file_not_exists "docroot/sites/default/files/somepublicfile.php"

  assert_dir_not_exists "vendor"
  assert_dir_not_exists "docroot/themes/custom/zzzsomecustomtheme/node_modules"

  assert_dir_not_exists "docroot/themes/custom/zzzsomecustomtheme/build"
  #assert_file_not_exists "docroot/themes/custom/zzzsomecustomtheme/scss/_components.scss"

  assert_dir_not_exists "tests/behat/screenshots"

  assert_file_not_exists ".data/db.sql"
  assert_file_not_exists ".data/db_2.sql"

  assert_file_not_exists "docroot/sites/default/settings.local.php"
  assert_file_not_exists "docroot/sites/default/services.local.yml"

  assert_file_not_exists "docker-compose.override.yml"

  assert_file_exists ".idea/some_ide_file"
  assert_file_exists ".vscode/some_ide_file"
  assert_file_exists "nbproject/some_ide_file"

  assert_file_not_exists "uncommitted_file.txt"

  assert_file_exists "scripts/drevops/download-db-acquia.sh"
  assert_file_exists "committed_file.txt"

  # The files would be committed to the consumer repo.
  assert_file_exists "composer.lock"
  assert_file_exists "docroot/themes/custom/star_wars/package-lock.json"
}
