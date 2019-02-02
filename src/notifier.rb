require 'terminal-notifier'

class Notifier

  def notify(target)
    if target.is_a? Hash
      notify_hash(target)
    else target.is_a? String
      notify_message(target)
    end
  end

  def notify_message(msg)
    TerminalNotifier.notify(msg.to_s, title: 'ip-checker', activate: 'com.apple.Terminal')
  end

  def notify_hash(msg)
    TerminalNotifier.notify(msg[:message], title: msg[:title], activate: 'com.apple.Terminal')
  end
end
