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

>   Just delete *.deploy_git* folder when meeting deployment errors

### hexo-abbrlink

```sh
npm install hexo-abbrlink --save
```

_config.yml:

-   `permalink`
-   `abbrlink`
    -   `alg`
    -   `rep`

### hexo-generator-search

```sh
npm install hexo-generator-search --save
```

_config.yml:

-   `search`
    -   `path`
    -   `field`
    -   `content`
    -   `format`
    -   `limit`

_config.butterfly.yml

-   `local_search`
    -   `enable`

### hexo-baidu-url-submit

```sh
npm install hexo-baidu-url-submit --save
```

_config.yml:

-   `deploy`
    -   `type`
-   `baidu_url_submit`
    -   `const`
    -   `host`
    -   `token`
    -   `path`

### hexo-helper-live2d

```sh
npm install --save hexo-helper-live2d
npm install --save live2d-widget-model-koharu
```

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

### SEO

```sh
npm install hexo-generator-sitemap --save
npm install hexo-generator-baidu-sitemap --save-dev
npm install hexo-generator-feed --save
```

_config.yml:

-   `url`
-   `sitemap`
    -   `path`

-   `baidusitemap`
    -   `path`
-   `feed`
    -   `type`
    -   `path`
    -   `limit`
-   `rss`
-   `plugins`

_config.butterfly.yml:

-   `site_verification`

### hexo-bilibili-bangumi

```sh
npm install hexo-bilibili-bangumi --save
```

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

### hexo-tag-aplayer

```sh
npm install hexo-tag-aplayer --save
```

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

### Gulp Compressing

```sh
npm install --global gulp-cli
npm install gulp -g --force
npm install gulp-htmlclean --save-dev
npm install --save gulp-html-minifier-terser
npm install gulp-clean-css --save-dev
npm install --save-dev gulp-uglify
npm install --save-dev gulp-babel @babel/core @babel/preset-env
npm install --save-dev gulp-imagemin
```

```sh
npm uninstall --global gulp-cli
npm uninstall gulp -g --force
npm uninstall gulp-htmlclean --save-dev
npm uninstall --save gulp-html-minifier-terser
npm uninstall gulp-clean-css --save-dev
npm uninstall --save-dev gulp-uglify
npm uninstall --save-dev gulp-babel @babel/core @babel/preset-env
npm uninstall --save-dev gulp-imagemin
```

package.json:

-   `type`

gulpfile.js

sw-template.js

themes\butterfly\layout\includes\third-party\pwanotice.pug

themes\butterfly\layout\includes\additional-js.pug:

-   `theme.pwa.enable`

source\img\\*

source\pwa\\*

_config.butterfly.yml:

-   `pwa`
    -   `enable`
    -   `manifest`
    -   `apple_touch_icon`
    -   `favicon_32_32`
    -   `favicon_16_16`
    -   `mask_icon`
    -   `theme_color`

### Background

_config.butterfly.yml:

-   `background`
-   `footer_bg`

### custom.css

source\css\custom.css

_config.butterfly.yml:

-   `inject`
    -   `head`
-   `background`

>   Just use **CSS Selector** in *custom.css* if willing to modify some components

### Electric Clock

```sh
npm install hexo-butterfly-clock --save
# 卸载原版电子钟
npm uninstall hexo-butterfly-clock
npm install hexo-butterfly-clock-anzhiyu --save
```

_config.butterfly.yml:

-   `electric_clock`

### Tags page

```sh
hexo new page tags
```

`type`

### Categories page

```sh
hexo new page categories
```

`type`

### Link page

```sh
hexo new page link
```

`type`

source\\_data\link.yml

### 404

_config.butterfly.yml:

-   `error_404`
    -   `enable`

### Navigation menu

https://fontawesome.com/icons?from=io

_config.butterfly.yml:

-   `menu`
    -   `Home`
    -   `Categories`
    -   `Tags`
    -   `Archives`
    -   `Links`

### hide_sidebar_menu_child

### Code Blocks

_config.butterfly.yml:

-   `highlight_theme`
-   `highlight_copy`
-   `highlight_lang`
-   `highlight_shrink`
-   `highlight_height_limit`

### Social Contact Icon

https://fontawesome.com/icons?from=io

_config.butterfly.yml:

-   `social`
    -   `fab fa-github`
    -   `fas fa-envelope`
    -   `fa-solid fa-blog`

### Article Introduction on Homepage

`index_post_content`

-   `method`

### Top Image

_config.butterfly.yml:

-   `disable_top_img`
-   `index_img`
-   `default_top_img`

### Avatar

_config.butterfly.yml:

-   `avatar`
    -   `img`
    -   `effect`

### Article Cover

_config.butterfly.yml:

-   `cover`
    -   `position`
    -   `default_cover`

### Article Meta

_config.butterfly.yml:

-   `post_meta`
    -   `page`
        -   `date_format`
    -   `post`
        -   `date_format`

### Article Copyright

_config.butterfly.yml:

-   `post_copyright`
    -   `author_href`

### Article Reward

_config.butterfly.yml:

-   `reward`
    -   `enable`
    -   `QR_code`

### Article Catalogue

_config.butterfly.yml:

-   `toc`
    -   `number`
    -   `style_simple`

### Related Article

_config.butterfly.yml:

-   `related_post`
    -   `date_type`

### Article Anchor

_config.butterfly.yml:

-   `anchor`

### Outdated Article Notice

_config.butterfly.yml:

-   `noticeOutdate`

### Article Edit

_config.butterfly.yml:

-   `post_edit`
    -   `enable`

### Image Description

_config.butterfly.yml:

-   `photofigcaption`

### About Copying

_config.butterfly.yml:

-   `copy`
    -   `copyright`
        -   `enable`
        -   `limit_count`

### Footer

```sh
npm install hexo-butterfly-footer-beautify --save
```

_config.butterfly.yml:

-   `footer`
    -   `owner`
        -   `since`
    -   `custom_text`
    -   `copyright`
-   `footer_beautify`

### Bottom Right Button

_config.butterfly.yml:

-   `translate`
    -   `enable`
-   `darkmode`
    -   `autoChangeMode`

### Sidebar

_config.butterfly.yml:

-   `aside`
    -   `position`
    -   `display`
    -   `card_author`
    -   `card_announcement`
    -   `card_categories`
    -   `card_tags`
    -   `card_archives`

### Markdown Math Formula

```sh
npm un hexo-renderer-marked --save # 如果有安装这个的话，卸载
npm un hexo-renderer-kramed --save # 如果有安装这个的话，卸载

npm i hexo-renderer-markdown-it --save # 需要安装这个渲染插件
npm install @neilsustc/markdown-it-katex --save #需要安装这个katex插件
```

_config.butterfly.yml:

-   `mathjax`
-   `katex`

_config.yml

-   `markdown`
    -   `plugins`

### Background Effects

_config.butterfly.yml:

-   `Background effects`

### Mouse click effects

_config.butterfly.yml:

-   `Background effects`
    -   `enable`

### Title Beautifying

_config.butterfly.yml:

-   `beautify`
    -   `field`

### Font

_config.butterfy.yml:

-   `font`
    -   `global-font-size`
    -   `font-family`
    -   `code-font-family`

### Website Subtitle

_config.butterfy.yml:

-   `subtitle`
    -   `enable`
    -   `source`
    -   `sub`

### Loading Animation

_config.butterfy.yml:

-   `preloader`

### Word Count

```sh
npm install hexo-wordcount --save 
```

_config.butterfy.yml:

-   `wordcount`

### Prefetch

_config.butterfy.yml:

-   `instantpage`

### Space Between Chinese Character and English Character

_config.butterfy.yml:

-   `pangu`
    -   `enable`

### Pjax

_config.butterfy.yml:

-   `pjax`
    -   `enable`

### hexo-butterfly-swiper

```sh
npm install hexo-butterfly-swiper-anzhiyu --save
npm uninstall hexo-butterfly-swiper-anzhiyu --save
npm install hexo-butterfly-swiper-anzhiyu-pro --save
npm uninstall hexo-butterfly-swiper-anzhiyu-pro --save
npm install hexo-butterfly-swiper --save
```

_config.butterfy.yml:

-   `swiper`
    -   `custom_css`
-   `pjax`
    -   `enable`

post toc:

-   `swiper_index`: 1-15 

### Double Row

```sh
npm i hexo-butterfly-article-double-row --save
```

_config.yml:

-   `butterfly_article_double_row`
-   `per_page`

