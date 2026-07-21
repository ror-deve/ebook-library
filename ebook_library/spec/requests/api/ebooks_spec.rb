require "rails_helper"

RSpec.describe "Ebooks API", type: :request do
  describe "GET /api/ebooks" do
    it "returns an empty array when no ebooks exist" do
      get "/api/ebooks"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it "returns ebooks ordered by newest first" do
      ebook1 = Ebook.new(title: "Ruby Book", author: "DHH", uploaded_at: 1.day.ago)
      ebook1.save(validate: false)

      ebook2 = Ebook.new(title: "Flutter Book", author: "Google", uploaded_at: Time.current)
      ebook2.save(validate: false)

      get "/api/ebooks"

      json = JSON.parse(response.body)

      expect(json.size).to eq(2)
      expect(json.first["title"]).to eq("Flutter Book")
    end
  end

  describe "POST /api/ebooks" do
    let(:pdf_file) do
      fixture_file_upload(
        Rails.root.join("spec/fixtures/files/test.pdf"),
        "application/pdf"
      )
    end

    before do
      FileUtils.mkdir_p(Rails.root.join("spec/fixtures/files"))
      File.write(
        Rails.root.join("spec/fixtures/files/test.pdf"),
        "%PDF-1.4 test content"
      )
    end

    it "creates an ebook with valid parameters" do
      post "/api/ebooks", params: {
        ebook: {
          title: "Ruby Book",
          author: "DHH",
          file: pdf_file
        }
      }

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)

      expect(json["title"]).to eq("Ruby Book")
      expect(json["author"]).to eq("DHH")
    end
    it "returns 422 when title is missing" do
      post "/api/ebooks", params: {
        ebook: {
          author: "DHH",
          file: pdf_file
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"])
        .to include("Title can't be blank")
    end

    it "returns 422 when file is missing" do
      post "/api/ebooks", params: {
        ebook: {
          title: "Ruby Book"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"])
        .to include("File can't be blank")
    end
  end

  describe "GET /api/ebooks/:id" do
    it "returns the ebook when it exists" do
      ebook = Ebook.new(title: "Ruby Book", author: "DHH", uploaded_at: Time.current)
      ebook.save(validate: false)

      get "/api/ebooks/#{ebook.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["title"]).to eq("Ruby Book")
      expect(json["author"]).to eq("DHH")
    end

    it "returns 404 when ebook does not exist" do
      get "/api/ebooks/99999"

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Ebook not found")
    end
  end

  describe "DELETE /api/ebooks/:id" do
    it "deletes the ebook and returns 204" do
      ebook = Ebook.new(title: "To Delete", uploaded_at: Time.current)
      ebook.save(validate: false)

      delete "/api/ebooks/#{ebook.id}"

      expect(response).to have_http_status(:no_content)
      expect(Ebook.find_by(id: ebook.id)).to be_nil
    end

    it "returns 404 when ebook does not exist" do
      delete "/api/ebooks/99999"

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Ebook not found")
    end
  end

  describe "GET /api/ebooks/:id/download" do
    it "returns 404 when ebook has no file attached" do
      ebook = Ebook.new(title: "No File Book", uploaded_at: Time.current)
      ebook.save(validate: false)

      get "/api/ebooks/#{ebook.id}/download"

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("File not found")
    end

    it "returns 404 when ebook does not exist" do
      get "/api/ebooks/99999/download"

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Ebook not found")
    end
  end

  describe "GET /api/ebooks/search" do
    it "filters ebooks by title or author" do
      ruby_book = Ebook.new(title: "Ruby Mastery", author: "John Doe", uploaded_at: Time.current)
      ruby_book.save(validate: false)

      flutter_book = Ebook.new(title: "Flutter Basics", author: "Jane Smith", uploaded_at: Time.current)
      flutter_book.save(validate: false)

      get "/api/ebooks/search?q=Ruby"

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json.length).to eq(1)
      expect(json.first["title"]).to eq("Ruby Mastery")

      # search author
      get "/api/ebooks/search?q=Jane"
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first["title"]).to eq("Flutter Basics")
    end
  end
end
