# SSH guard
I created this project because on the Linux server I noticed that our NTA (Network Traffic Analyzer) doesn't alert about suspicious SSH login attempts.

In the first run, the script gets the last 5 minutes of login attempts, saves the last run timestamp, and after that checks since that timestamp. If, from the last timestamp, there were more than 3 failed login attempts from one IP, this IP's connections by SSH will be blocked.

## How to use
Download script by command
```
git clone https://github.com/Doudmur/ssh-guard.git
cd ssh-guard
```

Set execute permissions
```
chmod +x ssh_guard.sh
```

Create cron job
```
sudo crontab -e
```

Add task
```
*/5 * * * * /path/to/directory/ssh-guard/ssh_guard.sh
```
By default script runs every 5 minutes, you can change it at any time what you want.

Scipts start working and will save data in root home directory:
- `.failed_rhosts.state`: Last run timestamp.
- `failed_rhosts.log`: Saved data about failed login attempts and alerts about blocking IPs.
- `blocked_ips.list`: Blocked IPs list file.
