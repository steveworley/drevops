# CLI container.
#
# All CLI operations performed in this container.
#
# @see https://hub.docker.com/r/uselagoon/php-8.1-cli-drupal/tags
# @see https://github.com/uselagoon/lagoon-images/tree/main/images/php-cli-drupal
FROM uselagoon/php-8.1-cli-drupal:22.7.0

# Add missing variables.
# @todo Remove once https://github.com/uselagoon/lagoon/issues/3121 is resolved.
ARG LAGOON_PR_HEAD_BRANCH=""
ENV LAGOON_PR_HEAD_BRANCH=$LAGOON_PR_HEAD_BRANCH
ARG LAGOON_PR_HEAD_SHA=""
ENV LAGOON_PR_HEAD_SHA=$LAGOON_PR_HEAD_SHA

# Set default values for environment variables. Any values provided in
# docker-compose.yml or .env file will override these values during build stage.
ENV WEBROOT=docroot \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_CACHE_DIR=/tmp/.composer/cache \
    MYSQL_HOST=mariadb \
    SIMPLETEST_DB=mysql://drupal:drupal@mariadb/drupal \
    SIMPLETEST_BASE_URL=http://nginx:8080 \
    SYMFONY_DEPRECATIONS_HELPER=disabled

# Strating from this line, Docker will add result of each command into a
# separate layer. These layers are then cached, and re-used when project is
# rebuilt.
# Note that layers are rebuilt only if files added into image with `ADD`
# have changed since the last build. So adding files that are most like to be
# rarely changed earlier in the build process (closer to the start of this
# file) adds more efficiency when working with stack - layers will be rarely
# rebuilt.

# Adding more tools.
RUN apk add --no-cache pv~1.6

# Adding patches and scripts.
COPY patches /app/patches
COPY scripts /app/scripts

# Copy files required for PHP dependencies resolution.
# Note that composer.lock is not explicitly copied, allowing to run the stack
# without existing lock file (this is not advisable, but allows to build
# using latest versions of packages). composer.lock should be comitted to the
# repository.
# File .env (and other environment files) is copied into image as it may be
# required by composer scripts to get some additions variables.
COPY composer.json composer.* .env* auth* /app/

# Install PHP dependencies, but without development dependencies. This is very
# important, because we do not want potential security issues to be exposed to
# production environment.
RUN COMPOSER_MEMORY_LIMIT=-1 composer install -n --no-dev --ansi --prefer-dist --optimize-autoloader

# Install NodeJS dependencies.
# Note that package-lock.json is not explicitly copied, allowing to run the
# stack without existing lock file (this is not advisable, but allows to build
# using latest versions of packages). package-lock.json should be comitted to
# the repository.
# File Gruntfile.sj is copied into image as it is required to generate
# front-end assets.
COPY docroot/themes/custom/your_site_theme/Gruntfile.js docroot/themes/custom/your_site_theme/.eslintrc.json docroot/themes/custom/your_site_theme/package.json docroot/themes/custom/your_site_theme/package* /app/docroot/themes/custom/your_site_theme/
COPY docroot/themes/custom/your_site_theme/patches /app/docroot/themes/custom/your_site_theme/patches

# Install NodeJS dependencies.
# Since Drupal does not use NodeJS for production, it does not matter if we
# install development dependencnies here - they are not exposed in any way.
RUN npm --prefix docroot/themes/custom/your_site_theme install --no-audit --no-progress --unsafe-perm

# Copy all files into appllication source directory. Existing files are always
# overridden.
COPY . /app

# Compile front-end assets. Running this after copying all files as we need
# sources to compile assets.
WORKDIR /app/docroot/themes/custom/your_site_theme
RUN npm run build

WORKDIR /app
