# Gravity Flip Online — beginner setup

This folder turns Gravity Flip into a public browser game with a shared global Top 100 leaderboard.

## What you'll use (free tiers)
- **Netlify Drop** to publish the game as a website.
- **Supabase** to store scores in a shared online database.

No Python, command prompt, build tools, or paid domain is required. Netlify gives you a public `*.netlify.app` address.

## Part A — Create the global leaderboard database

1. Go to https://supabase.com/ and create a free account/project.
2. In your project, open **SQL Editor** → **New query**.
3. Open `supabase_setup.sql` from this folder, copy all its contents into the SQL editor, and click **Run**.
4. In Supabase, open **Project Settings** → **API** (sometimes shown as **Data API / API Keys**).
5. Copy your **Project URL** and the **anon/public key**. Depending on the dashboard version, the public key may be called `anon` or `publishable`.
   - Never use or share the `service_role` or secret key in the website.

## Part B — Connect the website

1. Open `index.html` in Notepad or another text editor.
2. Near the top of its `<script>`, find:
   `const SUPABASE_URL = "PASTE_YOUR_SUPABASE_PROJECT_URL_HERE";`
   and paste your Project URL between the quotes.
3. Find:
   `const SUPABASE_ANON_KEY = "PASTE_YOUR_SUPABASE_ANON_KEY_HERE";`
   and paste the anon/public key between the quotes.
4. Save the file. Keep the quotes around both values.

## Part C — Publish the game for free

1. Make a folder named `gravity-flip-site`.
2. Put `index.html` inside it. You can also put `robots.txt` and `supabase_setup.sql` there, but only `index.html` is required for the game.
3. Open https://app.netlify.com/drop in your browser and sign in/create a free account.
4. Drag the `gravity-flip-site` folder onto the Netlify Drop page (or zip the folder and upload the zip if the page asks for that).
5. Netlify will give you a public URL such as `https://your-game-name.netlify.app`. Open it and test the game.

## Test the global leaderboard

1. Play until you crash.
2. Type a username (2–16 letters/numbers/spaces/underscore/hyphen).
3. Click **Submit last score**.
4. Open your public URL in another browser/device and click **Refresh leaderboard**. The same scores should appear.

## Google search

- Your game has a page title and description for search engines.
- Share the public URL with people and add it to any profiles/pages you control.
- Google indexing can take days or weeks and is not guaranteed. A free Netlify URL can be indexed; a custom domain is optional, not required.
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
Open **Creator / Admin Panel** in the sidebar and enter the creator code: `NOVA-OWNER-7429`. This is a read-only panel for viewing/exporting scores. Important: because this game is a static browser site, this code is visible in the downloaded page source and is not secure against determined users. Do not use it for private/destructive admin actions; server-side authentication is needed for that.
