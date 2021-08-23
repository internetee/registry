module Actions
  class AccountActivityCreate
    def initialize(account, new_balance, description, type)
      @account = account
      @new_balance = new_balance
      @description = description
      @type = type
    end

    def call
      validate_new_balance
      return false if @error

      calc_sum
      create_activity
      commit
    end

    def calc_sum
      @sum = @new_balance.to_f - @account.balance
    end

    def validate_new_balance
      return if @new_balance.blank?

      begin
        !Float(@new_balance).nil?
      rescue StandardError
        @error = true
      end
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
