require 'rails_helper'

RSpec.describe 'Search hotels by hotel id or destination id', type: :request do
  describe 'POST /hotels/search' do
    context 'Incorrect Payload' do
      it 'should give 400 bad request error when both hotels and destination parameter is not provided' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => [], 'destination' => nil }
        post '/hotels/search', params: payload.to_json, headers: headers

        # asserting that response status is 400
        expect(response.status).to eq(400)

        # asserting that response body is as expected
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'invalid_request',
                               'message' => 'Either hotels or destination parameters are required',
                               'type' => 'invalid_request_error'
                             }
                           })
      end

      it 'should give 400 bad request error when hotels parameter is not an array' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => 'iJhz', 'destination' => 5432 }
        post '/hotels/search', params: payload.to_json, headers: headers

        # asserting that response status is 400
        expect(response.status).to eq(400)

        # asserting that response body is as expected
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'invalid_request',
                               'message' => 'hotels parameter should be an array with all string ids',
                               'type' => 'invalid_request_error'
                             }
                           })
      end

      it 'should give 400 bad request error when hotels parameter is an array not having all string ids'  do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => ['iJhz', 'syJX', 12] , 'destination' => 5432 }
        post '/hotels/search', params: payload.to_json, headers: headers

        # asserting that response status is 400
        expect(response.status).to eq(400)

        # asserting that response body is as expected
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'invalid_request',
                               'message' => 'hotels parameter should be an array with all string ids',
                               'type' => 'invalid_request_error'
                             }
                           })
      end

      it 'should give 400 bad request error when destination parameter is not an integer'  do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => ['iJhz', 'syJX'], 'destination' => 'xyz' }
        post '/hotels/search', params: payload.to_json, headers: headers

        # asserting that response status is 400
        expect(response.status).to eq(400)

        # asserting that response body is as expected
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 'invalid_request',
                               'message' => 'destination paramter should be an integer',
                               'type' => 'invalid_request_error'
                             }
                           })
      end
    end

    context 'Valid Payload' do
      let(:acme_supplier_response) { JSON.parse(File.read(Rails.root.join('spec/fixtures/supplier_api_responses/acme.json'))) }
      let(:patagonia_supplier_response) { JSON.parse(File.read(Rails.root.join('spec/fixtures/supplier_api_responses/patagonia.json'))) }
      let(:paperflies_supplier_response) { JSON.parse(File.read(Rails.root.join('spec/fixtures/supplier_api_responses/paperflies.json'))) }

      before do
        # Stub the SupplierApiClient to return mocked responses
        allow(SupplierApiClient).to receive(:get_data).with('acme').and_return(acme_supplier_response)
        allow(SupplierApiClient).to receive(:get_data).with('patagonia').and_return(patagonia_supplier_response)
        allow(SupplierApiClient).to receive(:get_data).with('paperflies').and_return(paperflies_supplier_response)
      end

      it 'should return hotel fetched using hotel id' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => ['iJhz'] }
        post '/hotels/search', params: payload.to_json, headers: headers

        # asserting that response status is 200
        expect(response.status).to eq(200)

        # asserting that response body is as expected
        body = response_body
        expect(body.length).to eq(1)
        expect(body).to eq([{"id"=>"iJhz",
                             "destination_id"=>5432,
                             "name"=>"Beach Villas Singapore",
                             "location"=>{"address"=>"8 Sentosa Gateway, Beach Villas 098269", "city"=>"Singapore", "country"=>"SG", "latitude"=>1.264751, "longitude"=>103.824006},
                             "description"=>
                               "This 5 star hotel is located on the coastline of Singapore. Located at the western tip of Resorts World Sentosa, guests at the Beach Villas are guaranteed privacy while they enjoy spectacular views of glittering waters. Guests will find themselves in paradise with this series of exquisite tropical sanctuaries, making it the perfect setting for an idyllic retreat. Within each villa, guests will discover living areas and bedrooms that open out to mini gardens, private timber sundecks and verandahs elegantly framing either lush greenery or an expanse of sea. Guests are assured of a superior slumber with goose feather pillows and luxe mattresses paired with 400 thread count Egyptian cotton bed linen, tastefully paired with a full complement of luxurious in-room amenities and bathrooms boasting rain showers and free-standing tubs coupled with an exclusive array of ESPA amenities and toiletries. Guests also get to enjoy complimentary day access to the facilities at Asia’s flagship spa – the world-renowned ESPA. Surrounded by tropical gardens, these upscale villas in elegant Colonial-style buildings are part of the Resorts World Sentosa complex and a 2-minute walk from the Waterfront train station. Featuring sundecks and pool, garden or sea views, the plush 1- to 3-bedroom villas offer free Wi-Fi and flat-screens, as well as free-standing baths, minibars, and tea and coffeemaking facilities. Upgraded villas add private pools, fridges and microwaves; some have wine cellars. A 4-bedroom unit offers a kitchen and a living room. There's 24-hour room and butler service. Amenities include posh restaurant, plus an outdoor pool, a hot tub, and free parking.",
                             "amenities"=>
                               {"general"=>["pool", "businesscenter", "wifi", "drycleaning", "breakfast", "outdoorpool", "indoorpool", "childcare"],
                                "room"=>["aircon", "tv", "coffeemachine", "kettle", "hairdryer", "iron", "tub"]},
                             "images"=>
                               {"amenities"=>
                                  [{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/0.jpg", "description"=>"RWS"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg", "description"=>"Sentosa Gateway"}],
                                "rooms"=>
                                  [{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg", "description"=>"Double room"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/4.jpg", "description"=>"Bathroom"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/3.jpg", "description"=>"Double room"}],
                                "site"=>[{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/1.jpg", "description"=>"Front"}]},
                             "booking_conditions"=>
                               ["All children are welcome. One child under 12 years stays free of charge when using existing beds. One child under 2 years stays free of charge in a child's cot/crib. One child under 4 years stays free of charge when using existing beds. One older child or adult is charged SGD 82.39 per person per night in an extra bed. The maximum number of children's cots/cribs in a room is 1. There is no capacity for extra beds in the room.",
                                "Pets are not allowed.",
                                "WiFi is available in all areas and is free of charge.",
                                "Free private parking is possible on site (reservation is not needed).",
                                "Guests are required to show a photo identification and credit card upon check-in. Please note that all Special Requests are subject to availability and additional charges may apply. Payment before arrival via bank transfer is required. The property will contact you after you book to provide instructions. Please note that the full amount of the reservation is due before arrival. Resorts World Sentosa will send a confirmation with detailed payment information. After full payment is taken, the property's details, including the address and where to collect keys, will be emailed to you. Bag checks will be conducted prior to entry to Adventure Cove Waterpark. === Upon check-in, guests will be provided with complimentary Sentosa Pass (monorail) to enjoy unlimited transportation between Sentosa Island and Harbour Front (VivoCity). === Prepayment for non refundable bookings will be charged by RWS Call Centre. === All guests can enjoy complimentary parking during their stay, limited to one exit from the hotel per day. === Room reservation charges will be charged upon check-in. Credit card provided upon reservation is for guarantee purpose. === For reservations made with inclusive breakfast, please note that breakfast is applicable only for number of adults paid in the room rate. Any children or additional adults are charged separately for breakfast and are to paid directly to the hotel."]}])
      end

      it 'should return hotels fetched using multiple hotel ids' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => ['iJhz', 'SjyX'] }
        post '/hotels/search', params: payload.to_json, headers: headers

        # asserting that response status is 200
        expect(response.status).to eq(200)

        # asserting that response body is as expected
        body = response_body
        expect(body.length).to eq(2)
        expect(body).to eq([{"id"=>"iJhz",
                             "destination_id"=>5432,
                             "name"=>"Beach Villas Singapore",
                             "location"=>{"address"=>"8 Sentosa Gateway, Beach Villas 098269", "city"=>"Singapore", "country"=>"SG", "latitude"=>1.264751, "longitude"=>103.824006},
                             "description"=>
                               "This 5 star hotel is located on the coastline of Singapore. Located at the western tip of Resorts World Sentosa, guests at the Beach Villas are guaranteed privacy while they enjoy spectacular views of glittering waters. Guests will find themselves in paradise with this series of exquisite tropical sanctuaries, making it the perfect setting for an idyllic retreat. Within each villa, guests will discover living areas and bedrooms that open out to mini gardens, private timber sundecks and verandahs elegantly framing either lush greenery or an expanse of sea. Guests are assured of a superior slumber with goose feather pillows and luxe mattresses paired with 400 thread count Egyptian cotton bed linen, tastefully paired with a full complement of luxurious in-room amenities and bathrooms boasting rain showers and free-standing tubs coupled with an exclusive array of ESPA amenities and toiletries. Guests also get to enjoy complimentary day access to the facilities at Asia’s flagship spa – the world-renowned ESPA. Surrounded by tropical gardens, these upscale villas in elegant Colonial-style buildings are part of the Resorts World Sentosa complex and a 2-minute walk from the Waterfront train station. Featuring sundecks and pool, garden or sea views, the plush 1- to 3-bedroom villas offer free Wi-Fi and flat-screens, as well as free-standing baths, minibars, and tea and coffeemaking facilities. Upgraded villas add private pools, fridges and microwaves; some have wine cellars. A 4-bedroom unit offers a kitchen and a living room. There's 24-hour room and butler service. Amenities include posh restaurant, plus an outdoor pool, a hot tub, and free parking.",
                             "amenities"=>
                               {"general"=>["pool", "businesscenter", "wifi", "drycleaning", "breakfast", "outdoorpool", "indoorpool", "childcare"],
                                "room"=>["aircon", "tv", "coffeemachine", "kettle", "hairdryer", "iron", "tub"]},
                             "images"=>
                               {"amenities"=>
                                  [{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/0.jpg", "description"=>"RWS"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg", "description"=>"Sentosa Gateway"}],
                                "rooms"=>
                                  [{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg", "description"=>"Double room"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/4.jpg", "description"=>"Bathroom"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/3.jpg", "description"=>"Double room"}],
                                "site"=>[{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/1.jpg", "description"=>"Front"}]},
                             "booking_conditions"=>
                               ["All children are welcome. One child under 12 years stays free of charge when using existing beds. One child under 2 years stays free of charge in a child's cot/crib. One child under 4 years stays free of charge when using existing beds. One older child or adult is charged SGD 82.39 per person per night in an extra bed. The maximum number of children's cots/cribs in a room is 1. There is no capacity for extra beds in the room.",
                                "Pets are not allowed.",
                                "WiFi is available in all areas and is free of charge.",
                                "Free private parking is possible on site (reservation is not needed).",
                                "Guests are required to show a photo identification and credit card upon check-in. Please note that all Special Requests are subject to availability and additional charges may apply. Payment before arrival via bank transfer is required. The property will contact you after you book to provide instructions. Please note that the full amount of the reservation is due before arrival. Resorts World Sentosa will send a confirmation with detailed payment information. After full payment is taken, the property's details, including the address and where to collect keys, will be emailed to you. Bag checks will be conducted prior to entry to Adventure Cove Waterpark. === Upon check-in, guests will be provided with complimentary Sentosa Pass (monorail) to enjoy unlimited transportation between Sentosa Island and Harbour Front (VivoCity). === Prepayment for non refundable bookings will be charged by RWS Call Centre. === All guests can enjoy complimentary parking during their stay, limited to one exit from the hotel per day. === Room reservation charges will be charged upon check-in. Credit card provided upon reservation is for guarantee purpose. === For reservations made with inclusive breakfast, please note that breakfast is applicable only for number of adults paid in the room rate. Any children or additional adults are charged separately for breakfast and are to paid directly to the hotel."]},
                            {"id"=>"SjyX",
                             "destination_id"=>5432,
                             "name"=>"InterContinental Singapore Robertson Quay",
                             "location"=>{"address"=>"1 Nanson Road 238909", "city"=>"Singapore", "country"=>"SG", "latitude"=>nil, "longitude"=>nil},
                             "description"=>
                               "Enjoy sophisticated waterfront living at the new InterContinental® Singapore Robertson Quay, luxury's preferred address nestled in the heart of Robertson Quay along the Singapore River, with the CBD just five minutes drive away. Magnifying the comforts of home, each of our 225 studios and suites features a host of thoughtful amenities that combine modernity with elegance, whilst maintaining functional practicality. The hotel also features a chic, luxurious Club InterContinental Lounge. InterContinental Singapore Robertson Quay is luxury's preferred address offering stylishly cosmopolitan riverside living for discerning travelers to Singapore. Prominently situated along the Singapore River, the 225-room inspiring luxury hotel is easily accessible to the Marina Bay Financial District, Central Business District, Orchard Road and Singapore Changi International Airport, all located a short drive away. The hotel features the latest in Club InterContinental design and service experience, and five dining options including Publico, an Italian landmark dining and entertainment destination by the waterfront.",
                             "amenities"=>
                               {"general"=>["pool", "wifi", "aircon", "businesscenter", "bathtub", "breakfast", "drycleaning", "bar", "outdoorpool", "childcare", "parking", "concierge"],
                                "room"=>["minibar", "tv", "hairdryer"]},
                             "images"=>
                               {"amenities"=>[],
                                "rooms"=>
                                  [{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i93_m.jpg", "description"=>"Double room"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i94_m.jpg", "description"=>"Bathroom"}],
                                "site"=>
                                  [{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i1_m.jpg", "description"=>"Restaurant"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i2_m.jpg", "description"=>"Hotel Exterior"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i5_m.jpg", "description"=>"Entrance"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i24_m.jpg", "description"=>"Bar"}]},
                             "booking_conditions"=>[]}])
      end

      it 'should return empty array if there are no hotels matching the requested hotel ids' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => ['qwerty', 'lorem'] }
        post '/hotels/search', params: payload.to_json, headers: headers

        # asserting that response status is 200
        expect(response.status).to eq(200)

        # asserting that response body is as expected
        body = response_body
        expect(body.length).to eq(0)
        expect(body).to eq([])
      end

      it 'should return multiple hotels as per the matching destination id' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'destination' => 5432 }
        post '/hotels/search', params: payload.to_json, headers: headers

        # asserting that response status is 200
        expect(response.status).to eq(200)

        # asserting that response body is as expected
        body = response_body
        expect(body.length).to eq(2)
        expect(body).to eq([{"id"=>"iJhz",
                             "destination_id"=>5432,
                             "name"=>"Beach Villas Singapore",
                             "location"=>{"address"=>"8 Sentosa Gateway, Beach Villas 098269", "city"=>"Singapore", "country"=>"SG", "latitude"=>1.264751, "longitude"=>103.824006},
                             "description"=>
                               "This 5 star hotel is located on the coastline of Singapore. Located at the western tip of Resorts World Sentosa, guests at the Beach Villas are guaranteed privacy while they enjoy spectacular views of glittering waters. Guests will find themselves in paradise with this series of exquisite tropical sanctuaries, making it the perfect setting for an idyllic retreat. Within each villa, guests will discover living areas and bedrooms that open out to mini gardens, private timber sundecks and verandahs elegantly framing either lush greenery or an expanse of sea. Guests are assured of a superior slumber with goose feather pillows and luxe mattresses paired with 400 thread count Egyptian cotton bed linen, tastefully paired with a full complement of luxurious in-room amenities and bathrooms boasting rain showers and free-standing tubs coupled with an exclusive array of ESPA amenities and toiletries. Guests also get to enjoy complimentary day access to the facilities at Asia’s flagship spa – the world-renowned ESPA. Surrounded by tropical gardens, these upscale villas in elegant Colonial-style buildings are part of the Resorts World Sentosa complex and a 2-minute walk from the Waterfront train station. Featuring sundecks and pool, garden or sea views, the plush 1- to 3-bedroom villas offer free Wi-Fi and flat-screens, as well as free-standing baths, minibars, and tea and coffeemaking facilities. Upgraded villas add private pools, fridges and microwaves; some have wine cellars. A 4-bedroom unit offers a kitchen and a living room. There's 24-hour room and butler service. Amenities include posh restaurant, plus an outdoor pool, a hot tub, and free parking.",
                             "amenities"=>
                               {"general"=>["pool", "businesscenter", "wifi", "drycleaning", "breakfast", "outdoorpool", "indoorpool", "childcare"],
                                "room"=>["aircon", "tv", "coffeemachine", "kettle", "hairdryer", "iron", "tub"]},
                             "images"=>
                               {"amenities"=>
                                  [{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/0.jpg", "description"=>"RWS"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg", "description"=>"Sentosa Gateway"}],
                                "rooms"=>
                                  [{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg", "description"=>"Double room"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/4.jpg", "description"=>"Bathroom"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/3.jpg", "description"=>"Double room"}],
                                "site"=>[{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/1.jpg", "description"=>"Front"}]},
                             "booking_conditions"=>
                               ["All children are welcome. One child under 12 years stays free of charge when using existing beds. One child under 2 years stays free of charge in a child's cot/crib. One child under 4 years stays free of charge when using existing beds. One older child or adult is charged SGD 82.39 per person per night in an extra bed. The maximum number of children's cots/cribs in a room is 1. There is no capacity for extra beds in the room.",
                                "Pets are not allowed.",
                                "WiFi is available in all areas and is free of charge.",
                                "Free private parking is possible on site (reservation is not needed).",
                                "Guests are required to show a photo identification and credit card upon check-in. Please note that all Special Requests are subject to availability and additional charges may apply. Payment before arrival via bank transfer is required. The property will contact you after you book to provide instructions. Please note that the full amount of the reservation is due before arrival. Resorts World Sentosa will send a confirmation with detailed payment information. After full payment is taken, the property's details, including the address and where to collect keys, will be emailed to you. Bag checks will be conducted prior to entry to Adventure Cove Waterpark. === Upon check-in, guests will be provided with complimentary Sentosa Pass (monorail) to enjoy unlimited transportation between Sentosa Island and Harbour Front (VivoCity). === Prepayment for non refundable bookings will be charged by RWS Call Centre. === All guests can enjoy complimentary parking during their stay, limited to one exit from the hotel per day. === Room reservation charges will be charged upon check-in. Credit card provided upon reservation is for guarantee purpose. === For reservations made with inclusive breakfast, please note that breakfast is applicable only for number of adults paid in the room rate. Any children or additional adults are charged separately for breakfast and are to paid directly to the hotel."]},
                            {"id"=>"SjyX",
                             "destination_id"=>5432,
                             "name"=>"InterContinental Singapore Robertson Quay",
                             "location"=>{"address"=>"1 Nanson Road 238909", "city"=>"Singapore", "country"=>"SG", "latitude"=>nil, "longitude"=>nil},
                             "description"=>
                               "Enjoy sophisticated waterfront living at the new InterContinental® Singapore Robertson Quay, luxury's preferred address nestled in the heart of Robertson Quay along the Singapore River, with the CBD just five minutes drive away. Magnifying the comforts of home, each of our 225 studios and suites features a host of thoughtful amenities that combine modernity with elegance, whilst maintaining functional practicality. The hotel also features a chic, luxurious Club InterContinental Lounge. InterContinental Singapore Robertson Quay is luxury's preferred address offering stylishly cosmopolitan riverside living for discerning travelers to Singapore. Prominently situated along the Singapore River, the 225-room inspiring luxury hotel is easily accessible to the Marina Bay Financial District, Central Business District, Orchard Road and Singapore Changi International Airport, all located a short drive away. The hotel features the latest in Club InterContinental design and service experience, and five dining options including Publico, an Italian landmark dining and entertainment destination by the waterfront.",
                             "amenities"=>
                               {"general"=>["pool", "wifi", "aircon", "businesscenter", "bathtub", "breakfast", "drycleaning", "bar", "outdoorpool", "childcare", "parking", "concierge"],
                                "room"=>["minibar", "tv", "hairdryer"]},
                             "images"=>
                               {"amenities"=>[],
                                "rooms"=>
                                  [{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i93_m.jpg", "description"=>"Double room"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i94_m.jpg", "description"=>"Bathroom"}],
                                "site"=>
                                  [{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i1_m.jpg", "description"=>"Restaurant"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i2_m.jpg", "description"=>"Hotel Exterior"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i5_m.jpg", "description"=>"Entrance"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i24_m.jpg", "description"=>"Bar"}]},
                             "booking_conditions"=>[]}])
      end

      it 'should return empty array if there are no hotels matching the destination id params' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'destination' => 9876 }
        post '/hotels/search', params: payload.to_json, headers: headers

        # asserting that response status is 200
        expect(response.status).to eq(200)

        # asserting that response body is as expected
        body = response_body
        expect(body.length).to eq(0)
        expect(body).to eq([])
      end

      it 'should find hotels using the hotels param only and ignore destination param when both hotels and destination params are provided' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => ['iJhz'], 'destination' => 1122 }
        post '/hotels/search', params: payload.to_json, headers: headers

        # asserting that response status is 200
        expect(response.status).to eq(200)

        # asserting that response body is as expected
        body = response_body
        expect(body.length).to eq(1)
        expect(body).to eq([{"id"=>"iJhz",
                             "destination_id"=>5432,
                             "name"=>"Beach Villas Singapore",
                             "location"=>{"address"=>"8 Sentosa Gateway, Beach Villas 098269", "city"=>"Singapore", "country"=>"SG", "latitude"=>1.264751, "longitude"=>103.824006},
                             "description"=>
                               "This 5 star hotel is located on the coastline of Singapore. Located at the western tip of Resorts World Sentosa, guests at the Beach Villas are guaranteed privacy while they enjoy spectacular views of glittering waters. Guests will find themselves in paradise with this series of exquisite tropical sanctuaries, making it the perfect setting for an idyllic retreat. Within each villa, guests will discover living areas and bedrooms that open out to mini gardens, private timber sundecks and verandahs elegantly framing either lush greenery or an expanse of sea. Guests are assured of a superior slumber with goose feather pillows and luxe mattresses paired with 400 thread count Egyptian cotton bed linen, tastefully paired with a full complement of luxurious in-room amenities and bathrooms boasting rain showers and free-standing tubs coupled with an exclusive array of ESPA amenities and toiletries. Guests also get to enjoy complimentary day access to the facilities at Asia’s flagship spa – the world-renowned ESPA. Surrounded by tropical gardens, these upscale villas in elegant Colonial-style buildings are part of the Resorts World Sentosa complex and a 2-minute walk from the Waterfront train station. Featuring sundecks and pool, garden or sea views, the plush 1- to 3-bedroom villas offer free Wi-Fi and flat-screens, as well as free-standing baths, minibars, and tea and coffeemaking facilities. Upgraded villas add private pools, fridges and microwaves; some have wine cellars. A 4-bedroom unit offers a kitchen and a living room. There's 24-hour room and butler service. Amenities include posh restaurant, plus an outdoor pool, a hot tub, and free parking.",
                             "amenities"=>
                               {"general"=>["pool", "businesscenter", "wifi", "drycleaning", "breakfast", "outdoorpool", "indoorpool", "childcare"],
                                "room"=>["aircon", "tv", "coffeemachine", "kettle", "hairdryer", "iron", "tub"]},
                             "images"=>
                               {"amenities"=>
                                  [{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/0.jpg", "description"=>"RWS"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg", "description"=>"Sentosa Gateway"}],
                                "rooms"=>
                                  [{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg", "description"=>"Double room"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/4.jpg", "description"=>"Bathroom"},
                                   {"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/3.jpg", "description"=>"Double room"}],
                                "site"=>[{"link"=>"https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/1.jpg", "description"=>"Front"}]},
                             "booking_conditions"=>
                               ["All children are welcome. One child under 12 years stays free of charge when using existing beds. One child under 2 years stays free of charge in a child's cot/crib. One child under 4 years stays free of charge when using existing beds. One older child or adult is charged SGD 82.39 per person per night in an extra bed. The maximum number of children's cots/cribs in a room is 1. There is no capacity for extra beds in the room.",
                                "Pets are not allowed.",
                                "WiFi is available in all areas and is free of charge.",
                                "Free private parking is possible on site (reservation is not needed).",
                                "Guests are required to show a photo identification and credit card upon check-in. Please note that all Special Requests are subject to availability and additional charges may apply. Payment before arrival via bank transfer is required. The property will contact you after you book to provide instructions. Please note that the full amount of the reservation is due before arrival. Resorts World Sentosa will send a confirmation with detailed payment information. After full payment is taken, the property's details, including the address and where to collect keys, will be emailed to you. Bag checks will be conducted prior to entry to Adventure Cove Waterpark. === Upon check-in, guests will be provided with complimentary Sentosa Pass (monorail) to enjoy unlimited transportation between Sentosa Island and Harbour Front (VivoCity). === Prepayment for non refundable bookings will be charged by RWS Call Centre. === All guests can enjoy complimentary parking during their stay, limited to one exit from the hotel per day. === Room reservation charges will be charged upon check-in. Credit card provided upon reservation is for guarantee purpose. === For reservations made with inclusive breakfast, please note that breakfast is applicable only for number of adults paid in the room rate. Any children or additional adults are charged separately for breakfast and are to paid directly to the hotel."]}])
      end
    end

    context 'when encountering a JSON::ParserError' do
      before do
        allow(SupplierApiClient).to receive(:trigger_http_request).and_raise(JSON::ParserError)
      end

      it 'returns a specific 500 api_error response' do
        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => ['iJhz'], 'destination' => 1122 }
        post '/hotels/search', params: payload.to_json, headers: headers

        # assert status is 500
        expect(response.status).to eq(500)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 500,
                               'message' => 'Failed to parse response body as JSON',
                               'type' => 'api_error'
                             }
                           })
      end
    end

    context 'when encountering a 5xx server error response from Net::Http' do
      it 'returns a specific 500 api_error response when HTTPServerError response is received' do
        allow(SupplierApiClient).to receive(:trigger_http_request).and_return(Net::HTTPServerError.new(1, 500, 'Testing - HTTPServerError'))

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => ['iJhz'], 'destination' => 1122 }
        post '/hotels/search', params: payload.to_json, headers: headers

        # assert status is 500
        expect(response.status).to eq(500)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 500,
                               'message' => 'Internal Server Error',
                               'type' => 'http_network_error'
                             }
                           })
      end

      it 'returns a specific 500 api_error response when HTTPBadGateway response is received' do
        allow(SupplierApiClient).to receive(:trigger_http_request).and_return(Net::HTTPBadGateway.new(1, 502, 'Testing - HTTPBadGateway'))

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => ['iJhz'], 'destination' => 1122 }
        post '/hotels/search', params: payload.to_json, headers: headers

        # assert status is 500
        expect(response.status).to eq(500)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 500,
                               'message' => 'Internal Server Error',
                               'type' => 'http_network_error'
                             }
                           })
      end

      it 'returns a specific 500 api_error response when HTTPGatewayTimeout response is received' do
        allow(SupplierApiClient).to receive(:trigger_http_request).and_return(Net::HTTPGatewayTimeout.new(1, 504, 'Testing - HTTPGatewayTimeout'))

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => ['iJhz'], 'destination' => 1122 }
        post '/hotels/search', params: payload.to_json, headers: headers

        # assert status is 500
        expect(response.status).to eq(500)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 500,
                               'message' => 'Internal Server Error',
                               'type' => 'http_network_error'
                             }
                           })
      end

      it 'returns a specific 500 api_error response when HTTPInternalServerError response is received' do
        allow(SupplierApiClient).to receive(:trigger_http_request).and_return(Net::HTTPInternalServerError.new(1, 500, 'Testing - HTTPInternalServerError'))

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => ['iJhz'], 'destination' => 1122 }
        post '/hotels/search', params: payload.to_json, headers: headers

        # assert status is 500
        expect(response.status).to eq(500)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 500,
                               'message' => 'Internal Server Error',
                               'type' => 'http_network_error'
                             }
                           })
      end
    end

    context 'when encountering a non 200 response from Supplier API' do
      it 'returns error as received by Supplier API' do
        allow(SupplierApiClient).to receive(:trigger_http_request).and_return(Net::HTTPNotFound.new(1, 404, 'Testing - HTTPNotFound'))

        # Trigger API call
        headers = { 'Content-Type' => 'application/json' }
        payload = { 'hotels' => ['iJhz'], 'destination' => 1122 }
        post '/hotels/search', params: payload.to_json, headers: headers

        # assert status is 404
        expect(response.status).to eq(404)

        # asserting that response body have error details
        body = response_body
        expect(body).to eq({
                             'error' => {
                               'code' => 404,
                               'message' => 'Testing - HTTPNotFound',
                               'type' => 'api_error'
                             }
                           })
      end
    end
  end

  def response_body
    JSON.parse(response.body)
  end
end



