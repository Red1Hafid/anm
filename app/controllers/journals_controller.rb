class JournalsController < ApplicationController
    load_and_authorize_resource

    def index
        @journals = Journal.all.order('created_at desc').page(params[:page]).per(15)
        @journals.update_all(viewed: 1)
        @setting = Setting.find(1)
    end

end