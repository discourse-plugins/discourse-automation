# frozen_string_literal: true

DiscourseAutomation::Scriptable.add('send_pms') do
  version 1

  placeholder :sender_username
  placeholder :receiver_username

  field :sender, component: :user
  field :sendable_pms, component: :pms, accepts_placeholders: true

  triggerables %i[user_added_to_group stalled_wiki]

  script do |trigger, fields|
    placeholders = {
      sender_username: fields['sender']['username']
    }.merge(trigger['placeholders'] || {})

    trigger['users'].each do |user|
      placeholders[:receiver_username] = user.username

      fields['sendable_pms']['pms'].each do |sendable|
        pm = {}
        pm['title'] = utils.apply_placeholders(sendable['title'], placeholders)
        pm['raw'] = utils.apply_placeholders(sendable['raw'], placeholders)
        pm['target_usernames'] = Array(user.username)

        utils.send_pm(
          pm,
          sender: fields['sender']['username'],
          automation_id: automation.id,
          delay: sendable['delay'],
          encrypt: sendable['encrypt']
        )
      end
    end
  end
end
