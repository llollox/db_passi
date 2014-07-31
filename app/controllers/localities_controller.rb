class LocalitiesController < ApplicationController
	# GET /passes
  # GET /passes.json
  def index
    @localities = Locality.where(:pass_id => params[:pass_id])
    @list = []
    @localities.each do |locality|
      @list << getLocality(locality)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @list }
    end
  end

  # GET /passes/1
  # GET /passes/1.json
  def show
    @locality = Locality.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @locality }
    end
  end

  # GET /passes/new
  # GET /passes/new.json
  def new
    @locality = Locality.new

    @pass = nil
    if params[:pass_id]
      @pass = Pass.find(params[:pass_id].to_i)
    else
      @pass = Pass.all.first
    end
    @object = [@pass, @locality]


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @locality }
    end
  end

  # GET /passes/1/edit
  def edit
    @locality = Locality.find(params[:id])
    @pass = @locality.pass
    @object = @locality
  end

  # POST /passes
  # POST /passes.json
  def create
    @locality = Locality.new(params[:locality])

    respond_to do |format|
      if @locality.save
        format.html { redirect_to @locality, notice: 'Locality was successfully created.' }
        format.json { render json: @locality, status: :created, location: @locality }
      else
        format.html { render action: "new" }
        format.json { render json: @locality.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /passes/1
  # PUT /passes/1.json
  def update
    @locality = Locality.find(params[:id])

    respond_to do |format|
      if @locality.update_attributes(params[:locality])
        format.html { redirect_to @locality, notice: 'Locality was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @locality.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /passes/1
  # DELETE /passes/1.json
  def destroy
    @locality = Locality.find(params[:id])
    @pass = @locality.pass
    @locality.destroy


    respond_to do |format|
      format.html { redirect_to @pass }
      format.json { head :no_content }
    end
  end

  private

  def getLocality locality
    if locality.fraction_id.nil?
      return Municipality.find(locality.municipality_id)
    else
      return Fraction.find(locality.fraction_id)
    end
  end
end
