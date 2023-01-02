---
title: DecorationNotes
abbrlink: c5ad38d2
date: 2023-01-02 15:22:10
tags:
---

>   Note down all the modification based on *butterfly theme*

### Site Basic Info

_config.yml:

-   `title`
-   `subtitle`
-   `description`
-   `keywords`
-   `author`
-   `language`
-   `timezone`
-   `deploy`
    -   `type`
    -   `repo`
        -   `github`
        -   `gitee`
    -   `branch`

### hexo-abbrlink

_config.yml:

-   `permalink`
-   `abbrlink`
    -   `alg`
    -   `rep`

### hexo-generator-search

_config.yml:

-   `search`
    -   `path`
    -   `field`
    -   `content`

_config.butterfly.yml

-   `local_search`
    -   `enalbe`

### hexo-baidu-url-submit

_config.yml:

-   `deploy`
    -   `type`
-   `baidu_url_submit`
    -   `const`
    -   `host`
    -   `token`
    -   `path`

### hexo-helper-live2d

_config.yml:

-   `live2d`
    -   `enable`
    -   `scriptForm`
    -   `tagMode`
    -   `debug`
    -   `model`
        -   `use`
    -   `display`
        -   `position`
        -   `width`
        -   `height`
        -   `hOffset`
    -   `mobile`
        -   `show`

### hexo-generator-sitemap、hexo-generator-feed

_config.yml:

-   `baidusitemap`
    -   `path`
-   `feed`
    -   `type`
    -   `path`
    -   `limit`
-   `rss`
-   `plugins`

### hexo-bilibili-bangumi

_config.yml

-   `bangumi`
    -   `enable`
    -   `path`
    -   `vmid`
    -   `title`
    -   `quote`
    -   `show`
    -   `lazyload`
    -   `loading`
    -   `metaColor`
    -   `color`
    -   `webp`
    -   `progress`
    -   `extra_options`
        -   `key`
-   `cinema`
    -   `enable`
    -   `path`
    -   `vmid`
    -   `title`
    -   `quote`
    -   `show`
    -   `lazyload`
    -   `loading`
    -   `metaColor`
    -   `color`
    -   `webp`
    -   `progress`
    -   `extra_options`
        -   `key`

_config.butterfly.yml

-   `lazyload`
    -   `enable`
-   `menu`
    -   

### hexo-tag-aplayer

_config.yml

-   `aplayer`
    -   `meting`
    -   `asset_inject`

_config.butterfly.yml

-   `aplayerInject`
    -   `enable`
    -   `per_page`
-   `inject`
    -   `bottom`
        -   `<div class="aplayer" ..></div>`

### pwa

package.json:

-   `type`

gulpfile.js

sw-template.js

themes\butterfly\layout\includes\third-party\pwanotice.pug

themes\butterfly\layout\includes\additional-js.pug:

-   `theme.pwa.enable`

img\*

source\manifest.json

_config.butterfly.yml:

-   `pwa`
    -   `enable`
    -   `manifest`
    -   `apple_touch_icon`
    -   `favicon_32_32`
    -   `favicon_16_16`
    -   `mask_icon`
    -   `theme_color`
