module Actions
  class AccountActivityCreate
    def initialize(account, sum, description, type)
      @account = account
      @sum = sum
      @description = description
      @type = type
    end

    def call
      create_activity
      commit
    end

    def create_activity
      @activity = AccountActivity.new(account: @account,
                                      sum: @sum,
                                      currency: @account.currency,
                                      description: @description,
                                      activity_type: @type)
    end

    def commit
      @activity.save!
    end
  end
end
