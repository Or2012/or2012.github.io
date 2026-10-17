# Gravity Flip Online — beginner setup

This folder turns Gravity Flip into a public browser game with a shared global Top 100 leaderboard.

## Publish and preview this game

- GitHub Actions publishes the playable site from `gravity_flip_creator/` whenever code is pushed to `main`. The game is plain HTML, CSS, and JavaScript, so there is no compile step.
- In the repository's **Settings > Pages**, set the source to **GitHub Actions** once. After the first successful workflow run, GitHub shows the Pages URL there.
- To preview locally without uploading anything, double-click `Run Local Game.bat` in the repository folder. It opens `http://127.0.0.1:8000/` and starts a small local web server. Keep the server window open while playing; press Ctrl+C in that window to stop it. Python 3 must be installed.
- Local edits appear when you refresh the browser. They are not published until you commit and push them.

## What you'll use (free tiers)
- **GitHub Pages** with GitHub Actions to publish the game.
- **Supabase** to store scores in a shared online database.

GitHub Actions publishes the static game files automatically after you push to `main`. Local preview uses Python 3; see the instructions above.

## Part A — Create the global leaderboard database

1. Go to https://supabase.com/ and create a free account/project.
2. In your project, open **SQL Editor** → **New query**.
3. Open `supabase_setup.sql` from this folder, copy all its contents into the SQL editor, and click **Run**.
4. In Supabase, open **Project Settings** → **API** (sometimes shown as **Data API / API Keys**).
5. Copy your **Project URL** and the **anon/public key**. Depending on the dashboard version, the public key may be called `anon` or `publishable`.
   - Never use or share the `service_role` or secret key in the website.

## Part B - Database connection

The playable game in `gravity_flip_creator/index.html` is already configured for the current Supabase project. Its publishable key is intended for browser use; keep the database protected with the existing Row Level Security policies. Do not put a service-role or secret key in the game.

## Part C - Publish with GitHub Pages

1. This repository includes a GitHub Actions workflow that publishes the playable files from `gravity_flip_creator/`.
2. On GitHub, open the repository's **Settings > Pages** and choose **GitHub Actions** as the source.
3. Push changes to the `main` branch. The workflow deploys the game automatically; it does not need a compile step.
4. After the first successful run, open **Settings > Pages** to see the public game URL.


## Test the global leaderboard

1. Play until you crash.
2. Type a username (2–16 letters/numbers/spaces/underscore/hyphen).
3. Click **Submit last score**.
4. Open your public URL in another browser/device and click **Refresh leaderboard**. The same scores should appear.

## Google search

- Your game has a page title and description for search engines.
- Share the public URL with people and add it to any profiles/pages you control.
- Google indexing can take days or weeks and is not guaranteed. A GitHub Pages URL can be indexed; a custom domain is optional, not required.
- You can later use Google Search Console to request indexing of the public URL.

## Important limitations / safety

- This starter version allows anonymous score submissions. It checks username format and score range, but a determined player can fake a score or spam submissions. Do not use it for prizes or serious competition.
- For a more trustworthy leaderboard, the next upgrade would add login/rate limits and server-side score validation. A browser-only game cannot prove a score is legitimate.
- The Supabase public/anon key is intended to be visible in a browser. Database Row Level Security policies in `supabase_setup.sql` are essential. Never put a Supabase secret/service-role key in `index.html`.
- Free service limits and dashboards can change; check each provider's current terms.

## Files

- `index.html` — game + leaderboard UI
- `supabase_setup.sql` — database table and safe basic access rules
- `README.md` — these instructions
- `robots.txt` — lets search engines crawl the site


## Username uniqueness and fresh leaderboard
The game has no login or email. A name is reserved in Supabase when the player clicks **Save / change username**, and it stays reserved while the player is offline. Name matching is case-insensitive. The reservation is linked to a random ID stored in that browser, so the same browser can return without signing in. If the browser storage is cleared or the player switches devices, there is no login-based recovery; because you asked for no login, this is not a strong identity system. A player changing names leaves the old name reserved.

## Creator panel
Open **Creator / Admin Panel** in the sidebar and enter the creator code: `ora12`. This is a read-only panel for viewing/exporting scores. Important: because this game is a static browser site, this code is visible in the downloaded page source and is not secure against determined users. Do not use it for private/destructive admin actions; server-side authentication is needed for that.
