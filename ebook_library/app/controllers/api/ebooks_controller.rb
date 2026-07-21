module Api
  class EbooksController < ApplicationController
    before_action :set_ebook, only: [:show, :destroy, :download]

    def index
      @ebooks = Ebook.order(created_at: :desc)
      render json: @ebooks.map { |e| serialize_ebook(e) }
    end

    def search
      @ebooks = Ebook.search(params[:q]).order(created_at: :desc)
      render json: @ebooks.map { |e| serialize_ebook(e) }
    end
    
    def show
      render json: serialize_ebook(@ebook)
    end

    def create
      @ebook = Ebook.new(ebook_params)
      @ebook.uploaded_at = Time.current

      if params[:ebook][:file].present?
        @ebook.file_name  = params[:ebook][:file].original_filename
        @ebook.file_size  = params[:ebook][:file].size
        @ebook.file_type  = params[:ebook][:file].content_type
        @ebook.file.attach(params[:ebook][:file])
      end

      if params.dig(:ebook, :cover_image).present?
        @ebook.cover_image.attach(params[:ebook][:cover_image])
      end

      if @ebook.save
        render json: serialize_ebook(@ebook), status: :created
      else
        render json: { errors: @ebook.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @ebook.file.purge if @ebook.file.attached?
      @ebook.cover_image.purge if @ebook.cover_image.attached?
      @ebook.destroy
      head :no_content
    end

    def download
      if @ebook.file.attached?
        redirect_to rails_blob_url(@ebook.file, disposition: "attachment"),
                    allow_other_host: true
      else
        render json: { error: "File not found" }, status: :not_found
      end
    end

    private

    def set_ebook
      @ebook = Ebook.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Ebook not found" }, status: :not_found
    end

    def ebook_params
      params.require(:ebook).permit(:title, :author)
    end

    def serialize_ebook(ebook)
      data = ebook.as_json
      data['file_url'] = rails_blob_url(ebook.file) if ebook.file.attached?
      data['cover_url'] = rails_blob_url(ebook.cover_image) if ebook.cover_image.attached?
      data
    end

  end
end
