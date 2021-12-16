# Temp Local Admin
You’re a Config Manager administrator but your user account doesn’t have local administrator rights on any of the computers you have to support. What now?! If only you had access to an enterprise management tool that could run a PowerShell script on any computer it manages. Yeah, I went there.

Check out the full blog post at https://www.get-itguy.com/2021/12/temp-local-admin-through-mecm-run-script.html.

I wrote this script to add a user to the Administrators group on a computer for a variable time period. When time expires, a scheduled task runs once to remove the user from the Administrators group and 10 seconds later the scheduled task self-destructs in a scene only topped by Tom Cruise in Mission Impossible. When you run the script, an event is logged in the event viewer and a Teams channel is notified using a Teams web hook.

DISCLAIMER:  This method of adding a local administrator is far from secure. Unless you have Group Policy or some other tamper resistant 3rd party tool managing your Administrator group, your “temporary” administrator could make their administrator rights permanent.

IMPORTANT: In order for the Teams functionality of this to work, towards the bottom of the script you’ll need to replace https://YOUR.URI.HERE with your unique Teams Webhook URI URL. This process is outlined step by step in my blog at https://www.get-itguy.com/2021/12/temp-local-admin-through-mecm-run-script.html.
