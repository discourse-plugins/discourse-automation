# frozen_string_literal: true

require_relative '../discourse_automation_helper'

describe DiscourseAutomation::AutomationsController do
  describe '#trigger' do
    fab!(:automation) { Fabricate(:automation, script: 'nothing_about_us') }

    describe 'access' do
      context 'not logged in' do
        it 'is not found' do
          post "/automations/#{automation.id}/trigger.json"
          expect(response.status).to eq(404)
        end
      end

      context 'logged in' do
        context 'regular user' do
          fab!(:user) { Fabricate(:user) }

          before do
            sign_in(user)
          end

          it 'is not found' do
            post "/automations/#{automation.id}/trigger.json"
            expect(response.status).to eq(404)
          end
        end

        context 'moderator' do
          fab!(:moderator) { Fabricate(:moderator) }

          before do
            sign_in(moderator)
          end

          it 'is not found' do
            post "/automations/#{automation.id}/trigger.json"
            expect(response.status).to eq(404)
          end
        end

        context 'admin' do
          fab!(:admin) { Fabricate(:admin) }

          before do
            sign_in(admin)
          end

          it 'works' do
            post "/automations/#{automation.id}/trigger.json"
            expect(response.status).to eq(200)
          end

          context 'using a user api key' do
            let(:user_api_key) { Fabricate(:user_api_key, user: admin) }

            before do
              user_api_key.scopes = [UserApiKeyScope.new(name: 'discourse-automation:automations_trigger')]
              user_api_key.save!
            end

            it 'works' do
              post "/automations/#{automation.id}/trigger.json", {
                params: { context: { foo: :bar } },
                headers: {
                  HTTP_USER_API_KEY: user_api_key.key
                }
              }
              expect(response.status).to eq(200)
            end
          end
        end
      end
    end

    describe 'triggering' do
      fab!(:admin) { Fabricate(:admin) }
      fab!(:automation) { Fabricate(:automation, script: 'something_about_us', trigger: 'api_call') }

      before do
        sign_in(admin)
      end

      it 'passes the params' do
        output = JSON.load(capture_stdout do
          post "/automations/#{automation.id}/trigger.json", { params: { foo: '1', bar: '2' } }
        end)

        expect(output['foo']).to eq('1')
        expect(output['bar']).to eq('2')
        expect(response.status).to eq(200)
      end
    end
  end
end
