# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Static HTML/CSS portfolio website. Single-page site with all sections: About, Services, Courses, Books, Community, and Contact. Will be deployed to AWS using the S3 and Cloudfront, provisioned with Terraform. 

## Development

There is no build process, package manager, or test suite. To preview locally, serve the files with any static file server:

```bash
# Python (simplest option)
python3 -m http.server 8080

# Nginx (production deployment target)
sudo cp -r . /var/www/html/
sudo systemctl restart nginx
```

## Architecture

This is a pure static website with **Pure HTML5 with CSS3, No Javascript, No build step. No frameworks**. There is no test suite, and no linter configured. 

- `index.html` — single-page site with all sections: navbar, hero, about, services, courses, books, community stats, contact, footer
- `style.css` — all styling (1145 lines); uses CSS Grid/Flexbox, CSS keyframe animations, and media query breakpoints at 900px and 600px
- `privacy.html`, `terms.html` — standalone pages with inline styles
- `images/` — all static assets (~3.8 MB total)

**External dependency**: Font Awesome 6.5.0 loaded via CDN for icons.

## DMI Deployment Requirement

Students must add ownership proof to the footer before submission. The format is:

```
Deployed by: DMI Cohort 2 | [Name] | Group [N] | Week 1 | [Date]
```

This line goes in the footer section of `index.html`.

## Key Conventions

- **No JavaScript**: Keep the site pure HTML/CSS. Do not introduce any JS, even for minor interactions.
- **Images**: Place all static assets in the `images/` directory. Optimize before adding to keep total size reasonable.
- **CSS styling**: CSS uses mobile first approach. Breakpoints at 900px, 768px, and 600px.
