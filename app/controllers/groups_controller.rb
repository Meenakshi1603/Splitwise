

class GroupsController < ApplicationController
  before_action :authenticate_user!

  def index
    @groups = current_user.groups.includes(:users)
    render :index
  end

  def new
    @group = Group.new
    @users = User.where.not(id: current_user.id)
  end

  def create
    @group = current_user.groups.new(group_params)

    if @group.save
      @group.memberships.create!(user_id: current_user.id)
      params[:group][:user_ids].each do |user_id|
        @group.memberships.create(user_id: user_id) unless Membership.exists?(group_id:
          @group.id, user_id: user_id)
      end
      redirect_to groups_path, notice: 'Group created successfully!'
    else
      @users = User.where.not(id: current_user.id)
      flash.now[:alert] = @group.errors.full_messages.join(', ')
      render :new
    end
  end

  def destroy
     @group = Group.find(params[:id])
    @group.destroy
    redirect_to groups_path, notice: 'Group  deleted.'
  end


def part_of
    @groups = current_user.group_memberships
  end
  private






  def group_params
    params.require(:group).permit(:name, user_ids: [])
  end
end
