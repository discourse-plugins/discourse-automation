# frozen_string_literal: true

require_relative '../discourse_automation_helper'

describe DiscourseAutomation::AdminDiscourseAutomationAutomationsController do
  fab!(:automation) { Fabricate(:automation) }

  context 'logged as admin' do
    fab!(:admin) { Fabricate(:admin) }

    before { sign_in(admin) }

    describe '#trigger' do
      it 'triggers the automation' do
        output = capture_stdout do
          post "/admin/plugins/discourse-automation/automations/#{automation.id}/trigger.json"
        end

        expect(output).to include("\kind\":\"#{DiscourseAutomation::Triggerable::ApiCall}\"")
      end
    end

    describe '#update' do
      it 'updates the automation' do
        put "/admin/plugins/discourse-automation/automations/#{automation.id}.json", params: { automation: { trigger: 'another-trigger' } }
        expect(response.status).to eq(200)
      end

      context 'invalid field’s component' do
        it 'errors' do
          put "/admin/plugins/discourse-automation/automations/#{automation.id}.json", params: {
            automation: {
              script: automation.script,
              trigger: automation.trigger,
              fields: [
                { name: 'foo', component: 'bar' }
              ]
            }
          }

          expect(response.status).to eq(422)
        end
      end

      context 'invalid field’s metadata' do
        it 'errors' do
          put "/admin/plugins/discourse-automation/automations/#{automation.id}.json", params: {
            automation: {
              script: automation.script,
              trigger: automation.trigger,
              fields: [
                { name: 'sender', component: 'users', metadata: { baz: 1 } }
              ]
            }
          }

          expect(response.status).to eq(422)
        end
      end
    end

    describe '#destroy' do
      it 'destroys the bookmark' do
        delete "/admin/plugins/discourse-automation/automations/#{automation.id}.json"
        expect(DiscourseAutomation::Automation.find_by(id: automation.id)).to eq(nil)
      end
    end
  end

  context 'not logged as admin' do
    describe '#update' do
      it 'raises a 404' do
        put "/admin/plugins/discourse-automation/automations/#{automation.id}.json", params: {}
        expect(response.status).to eq(404)
      end
    end

    describe '#trigger' do
      it 'raises a 404' do
        post "/admin/plugins/discourse-automation/automations/#{automation.id}/trigger.json"
        expect(response.status).to eq(404)
      end
    end

    describe '#destroy' do
      it 'raises a 404' do
        delete "/admin/plugins/discourse-automation/automations/#{automation.id}.json"
        expect(response.status).to eq(404)
      end
    end
  end
end
