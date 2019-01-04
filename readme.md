**Inactive** as Slack does not allow just any workspace to create legacy tokens anymore, there is not much of a point on continueing development (for me at least). I might pick it back up once slack might release some more flexible (non app) authentication methods. However I am not expecting anyting like this soon.

If you want to continue development. Feel free to create merge requests, I will review and approve, or give maintainership.

# CollabApp
(Formerly SlackDesk)

An alternative client for Slack written in swift. V2.

Short demo:
![SlackDesk screenshot](Resources/collabapp.gif "SlackDesk demo")

The app is adaptive to the MacOs color scheme (light/dark) 💪

## Why?

The official client for me was pretty resource heavy. With around 8 teams active
the memory consumption was above 1GB.

This inspired me, together with my interest in learning a new programming
language to develop a simpler client, natively for os x.

The client is build with the vision of giving as much of the features, but to
keep it from being distractive and resource heavy

LOW! 🙏 Memory usage (as per demo):

![SlackDesk memory screenshot](Resources/usage.png "SlackDesk resource screenshot")

__Disclaimer__

This is my first project I have ever written in Swift. I am pretty sure that many
improvements can be made (and will be made) over time. Feel free to point me to
better implementation techniques if you feel they can improve the client.

Pull requests and bug reports are welcome!

## What works?

- Multiple clients using [legacy tokens](https://api.slack.com/custom-integrations/legacy-tokens)
- Chatting
- Groups, private channels, public channels
- User list with status
- Links and markdown rendering of messages
- Emoji rendering (most of them) 💪
- Live adding of channels via other clients
- Notification of new messages (without control)
- Links to files
- Drag and drop file uploads 🤳

__What does not work__

Many things, but that is the point. I will try to add more features but I will
add them one by one:

- Inline Image viewing (File links are already present)
- Snippet viewing
- Channel creation
- Notification manager
- Status manager
- Suggest yours!

If you want a full featured Slack client, you should use the official client.
However, the end goal is to implement every feature into collabApp

## Usage

Download the [latest release](https://github.com/haringsrob/CollabApp/releases) and copy it to your applications
folder.

Then go and create [legacy tokens](https://api.slack.com/custom-integrations/legacy-tokens)

Last is to add the legacy tokens to the settings pane (CMD+,)

Restart the client for the new connections to be initialized.

## Developing

If you would like to contribute, clone the repository.

As this project is using CocoaPods, you should run `pod install` after cloning.

After running `pod install` open the `collabapp.xcworkspace`

All code goes thorough pull requests together with an issue explaining the
motivation for the code.

All help is welcome and much appreciated.

## Tests

Some basic testing is implemented.

For mocking a websocket we can use the following:

```
gem install em-websocket --user-install
gem install faker --user-install
```

ruby mock_server.rb
