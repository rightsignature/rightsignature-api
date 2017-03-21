require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::RailsStyle do
  describe "send_document" do
    before do
      @time = Time.now
      @document_details = {
         document:  {
           guid: "MYGUID",
           created_at:        (@time+0).strftime("%Y-%m-%dT%H:%M:%S%:z"),
           completed_at:      (@time+1).strftime("%Y-%m-%dT%H:%M:%S%:z"),
           last_activity_at:  (@time+2).strftime("%Y-%m-%dT%H:%M:%S%:z"),
           expires_on:        (@time+3).strftime("%Y-%m-%dT%H:%M:%S%:z"),
           is_trashed: "false",
           size: "4096",
           content_type: "pdf",
           original_filename: "MyFilename.pdf",
           signed_pdf_checksum: "SOME123CHECKSUM",
           subject: "some subject",
           message: "some message",
           processing_state: "done-processing",
           merge_state: "done-processing",
           state: "signed",
           callback_location: "https://example.com/callback",
           tags: "hel%2Clo,the%22re,abc:de%3Af",
           recipients:  {
             recipient:  [
              {  name: "Jack Employee",
                 email: "jack@company.com",
                 must_sign: "true",
                 document_role_id: "signer_A",
                 role_id: "signer_A",
                 state: "signed",
                 is_sender: "false",
                 viewed_at: (@time+0).strftime("%Y-%m-%dT%H:%M:%S%:z"),
                 completed_at: (@time+1).strftime("%Y-%m-%dT%H:%M:%S%:z")
              },
              {  name: "Jill Employee",
                 email: "jill@company.com",
                 must_sign: "false",
                 document_role_id: "cc_A",
                 role_id: "cc_A",
                 state: "pending",
                 is_sender: "true",
                 viewed_at: nil,
                 completed_at: nil
              }
          ]},
           audit_trails:  {
             audit_trail:  [
              {  timestamp: (@time+0).strftime("%Y-%m-%dT%H:%M:%S%:z"),
                 keyword: "created",
                 message: "Document created via the RightSignature API by Jill Employee (jill@company.com)."
              },
              {  timestamp: (@time+1).strftime("%Y-%m-%dT%H:%M:%S%:z"),
                 keyword: "viewed",
                 message: "Document viewed by Jack Employee (jack@company.com)."
              },
              {  timestamp: (@time+2).strftime("%Y-%m-%dT%H:%M:%S%:z"),
                 keyword: "signed",
                 message: "Document signed by Jack Employee (jack@company.com) with drawn signature."
              },
              {  timestamp: (@time+3).strftime("%Y-%m-%dT%H:%M:%S%:z"),
                 keyword: "complete",
                  message: "All parties have signed document. Signed copies sent to: Jack Employee and Jill Employee."
              }
          ]},
           pages:  {
             page:
               { page_number: "1",
                 original_template_guid: "a_Template_GUID",
                 original_template_filename: "MyFilename.pdf"}
          },
           form_fields:  {
             form_field: [
              {  id: "a_22177095_3d68450d37e04db69218abc886ebda0f_528356597",
                 name: "Form Field A",
                 role_id: "signer_A",
                 value: "Some Value A",
                 page: "1"
              },
              {  id: "a_22177095_3d68450d37e04db69218abc886ebda0f_528356595",
                 name: "Form Field B",
                 role_id: "signer_A",
                 value: "Some Value B",
                 page: "1"
              },
          ]},
         original_url:    "https%3A%2F%2Fs3.amazonaws.com%2Fdocs.rightsignature.com%2Fassets%2F22177095%2FMyFilename.pdf%3FAWSAccessKeyId%3DKEY%26Expires%3D#{@time.to_i}%26Signature%3DSOMESIG",
         pdf_url:         "https%3A%2F%2Fs3.amazonaws.com%2Fdocs.rightsignature.com%2Fassets%2F22177095%2FMyFilename.pdf%3FAWSAccessKeyId%3DKEY%26Expires%3D#{@time.to_i}%26Signature%3DSOMESIG",
         thumbnail_url:   "https%3A%2F%2Fs3.amazonaws.com%2Fdocs.rightsignature.com%2Fassets%2F22177095%2Fa_Some_Id_s_p1_t.png%3FAWSAccessKeyId%3DKEY%26Expires%3D#{@time.to_i}%26Signature%3DSOMESIG",
         large_url:       "https%3A%2F%2Fs3.amazonaws.com%2Fdocs.rightsignature.com%2Fassets%2F22177095%2Fa_Some_id_s_p1.png%3FAWSAccessKeyId%3DKEY%26Expires%3D#{@time.to_i}%26Signature%3DSOMESIG",
         signed_pdf_url:  "https%3A%2F%2Fs3.amazonaws.com%2Fdocs.rightsignature.com%2Fassets%2F22177095%2FMyFilename-signed.pdf%3FAWSAccessKeyId%3DKEY%26Expires%3D#{@time.to_i}%26Signature%3DSOMESIG",
      }}

      @template_details = {
       template:  {
         type: "Document",
         guid: "MYGUID",
         created_at: "2017-03-03T09:24:18-08:00",
         filename: "fw8ben.pdf",
         size: "69211",
         content_type: "pdf",
         page_count: "1",
         subject: "W-8BEN Tax Form",
         message: "Please sign this document.",
         tags: "hel%2Clo,the%22re,abc:de%3Af",
         processing_state: "done-processing",
         roles:  {
           role:  [
              { role: "Document Sender",
                name: "Document Sender",
                must_sign: "false",
                document_role_id: "cc_A",
                is_sender: "true"
              },
              { role: "Non-US Person",
                name: "Non-US Person",
                must_sign: "true",
                document_role_id: "signer_A",
                is_sender: "false"
              }
            ]
          },
         merge_fields: {
           merge_field: [
           {id: "a_21470713_efe491a03af24760b457ea0c12061d55_512294075",
            name: "Effective Date",
            page: "1",
            value: nil
           },
           {id: "a_21470713_efe491a03af24760b457ea0c12061d55_512294076",
            name: "Content URL",
            page: "1",
            value: nil
           },
         ]},
         pages:  {
           page:  {
             page_number: "1",
             original_template_guid: "a_22168482_df3f2b8fc9894d779d1f07c2d398ce70",
             original_template_filename: "fw8ben.pdf"
          }},
         thumbnail_url: "https%3A%2F%2Fs3.amazonaws.com%2Fdocs.rightsignature.com%2Fassets%2F22168482%2Fa_Some_Id_p1_t.png%3FAWSAccessKeyId%3DKey%26Expires%3D#{@time.to_i}%26Signature%3DSomeSig",
      }}

    end

    it 'can accept strings or symbols for options' do

      @rs.should_receive(:post).with('/api/templates/GUID123/prepackage.xml',
        {}
      ).and_return({"template" => {
        "guid" => "a_123985_1z9v8pd654",
        "subject" => "subject template",
        "message" => "Default message here",
      }})

      @rs.should_receive(:post).with('/api/templates.xml', {:template => {
          :guid => "a_123985_1z9v8pd654",
          :action => "send",
          :subject => "sign me",
          :roles => []
        }})

      @rs.prepackage_and_send("GUID123", [], {"subject" => "sign me"})
    end

    it 'escapes tags' do
      @rs.should_receive(:get).with('/api/templates.xml', {tags: "hel%2Clo,the%22re,key:val%3Aue"})
      @rs.templates_list(tags: ["hel,lo", "the\"re",{key: "val:ue"}])
    end

    it 'can accept metadata and tags' do
      @rs.should_receive(:get).with('/api/templates.xml', {tags: "hello,there,abc:def"})
      @rs.templates_list(
        tags: ["hello", "there"],
        metadata: {"abc" => "def"},
      )
    end

    it 'escapes metadata and tags' do
      @rs.should_receive(:get).with('/api/templates.xml', {tags: "hel%2Clo,the%22re,abc:de%3Af"})
      @rs.templates_list(
        tags: ["hel,lo", "the\"re"],
        metadata: {"abc" => "de:f"},
      )
    end

    it 'can accept hash-based data' do
      @rs = RightSignature::RailsStyle.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123", :api_token => "APITOKEN"})

      @rs.should_receive(:post).with('/api/templates/GUID123/prepackage.xml',
        {}
      ).and_return({"template" => {
        "guid" => "a_123985_1z9v8pd654",
        "subject" => "subject template",
        "message" => "Default message here",
        :merge_fields => [
          {:merge_field => {
            :value => "123456",
            "@merge_field_id" => "123_abc_78"
          }},
          {merge_field: {
            value: "654321",
            "@merge_field_id": "321_cba_87"
          }}
        ]
      }})

      @rs.should_receive(:post).with('/api/templates.xml', {:template => {
          :guid => "a_123985_1z9v8pd654",
          :action => "send",
          :subject=>"subject template",
          :tags=>[
            {:tag=>{:name=>"a"}},
            {:tag=>{:name=>"tag"}},
            {:tag=>{:name=>"some", :value=>"data"}}
          ],
          :merge_fields=>[
            {:merge_field=>{:value=>"123456", "@merge_field_id"=>"123_abc_78"}},
            {:merge_field=>{:value=>"654321", "@merge_field_id"=>"321_cba_87"}}
          ],
          :roles => [
            {:role => {
              :name => "John Employee",
              :email => "john@employee.com",
              "@role_id" => "signer_A"
            }},
            {role: {
              name: "Jill Employee",
              email: "jill@employee.com",
              "@role_id" => "signer_B",
            }},
          ],
      }})

      @rs.prepackage_and_send(
        "GUID123",
        { signer_A: {
            :name => "John Employee",
            :email => "john@employee.com"
          },
          signer_B: {
            name: "Jill Employee",
            email: "jill@employee.com",
          }
        },
        {:merge_fields => {
          "123_abc_78" => "123456",
          "321_cba_87": "654321",
          },
          :use_merge_field_ids => true,
          tags: ["a","tag"],
          metadata:  {
            some: :data,
            other: nil
          }
        })
    end

    it 'should format template details' do
      @rs = RightSignature::RailsStyle.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123", :api_token => "APITOKEN"})

      @rs.should_receive(:get).with('/api/templates/MYGUID.xml', {}).and_return(@template_details)

      @doc = @rs.template_details('MYGUID')

      expect(@doc).to include(
        metadata: {"abc" => "de:f"},
        tags: ["hel,lo", "the\"re"],
        roles: include(
          "cc_A" => include(document_role_id: "cc_A"),
          "signer_A" => include(document_role_id: "signer_A"),
        ),
        merge_fields: include(
          "Effective Date" => include(name: "Effective Date"),
          "Content URL" => include(name: "Content URL")
        ),
        original_template_guid: "a_22168482_df3f2b8fc9894d779d1f07c2d398ce70",
        original_template_filename: "fw8ben.pdf",
      )
    end

    it 'should format document details' do
      @rs = RightSignature::RailsStyle.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123", :api_token => "APITOKEN"})

      @rs.should_receive(:get).with('/api/documents/MYGUID.xml').and_return(@document_details)
      @doc = @rs.document_details('MYGUID')

      # Only measuring the things that are different from normal document_details
      expect(@doc).to include(
        metadata: {"abc" => "de:f"},
        tags: ["hel,lo", "the\"re"],
        original_url: "https://s3.amazonaws.com/docs.rightsignature.com/assets/22177095/MyFilename.pdf?AWSAccessKeyId=KEY&Expires=#{@time.to_i}&Signature=SOMESIG",
        original_template_guid: "a_Template_GUID",
        original_template_filename: "MyFilename.pdf",
        recipients: include(
          "signer_A" => include(
            name: "Jack Employee",
          ),
          "cc_A" => include(
            name: "Jill Employee",
          ),
        ),
        audit_trails: include(
          (@time+0).strftime("%Y-%m-%dT%H:%M:%S%:z") => include(
            keyword: "created",
          ),
          (@time+1).strftime("%Y-%m-%dT%H:%M:%S%:z") => include(
            keyword: "viewed",
          ),
          (@time+2).strftime("%Y-%m-%dT%H:%M:%S%:z") => include(
            keyword: "signed",
          ),
          (@time+3).strftime("%Y-%m-%dT%H:%M:%S%:z") => include(
            keyword: "complete",
          ),
        ),
        form_fields: include(
          "Form Field A" => include(
            value: "Some Value A",
          ),
          "Form Field B" => include(
            value: "Some Value B"
          ),
        ),
      )
    end
  end
end
