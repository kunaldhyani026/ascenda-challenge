# Hotels data merge

## Problem Statement

[Hotels Data Merge - Description](https://gist.github.com/mal90/90eb57055c3f2cbdbc6c3b80fb165b92)
## Running the Application
### Prerequisites
Make sure you have Docker installed on your system. You can download and install Docker from [here](https://www.docker.com/get-started).
### Setting up the Application / Deploy using docker images
- Pull the docker image:
  ```
  docker pull kunaldhyani026/ascenda-challenge-image
  ```
- Run the container:
  ```
  docker run -p 3000:3000 --name ascenda-challenge-container -d kunaldhyani026/ascenda-challenge-image
  ```
- APIs accessible at `http://localhost:3000/` [Use postman or cURL to hit JSON API requests]

  Example:
  ```
  curl --location 'localhost:3000/hotels/search' --header 'Content-Type: application/json' --data '{"hotels": ["iJhz"]}'
  ```

### Test Pipeline
- To run the specs:
  - Login to container: `docker exec -it ascenda-challenge-container bash`
  - Run: `rspec`
### Request format
Endpoint: ```POST /hotels/search```

Request body: 
  - ```hotels```: An array of string values
  - ```destination```: Integer

Atleast one of the request body parameter is required. In case user passes valid values for both, only ```hotels``` parameter is considered to fetch the response.

Use any API testing tool (eg: Postman, cURL) to hit JSON API request.

Example:
```
curl --location 'localhost:3000/hotels/search' --header 'Content-Type: application/json' --data '{"hotels": ["iJhz", "f8c9"]}'
```
```
curl --location 'localhost:3000/hotels/search' --header 'Content-Type: application/json' --data '{"destination": 5432}'
```

### Response format
Response is an array of hashes (eg: [{}, {}]). Each hash represent a hotel with below properties:
- **id**: String
- **destination_id**: Integer
- **name**: String
- **location**: Hash
  - **address**: String
  - **city**: String
  - **country**: String
  - **lat**: Float
  - **lng**: Float
- **description**: String
- **amenities**: Hash
  - **general**: Array of String
  - **room**: Array of String
- **images**: Hash
  - **amenities**: Array of hashes (eg: [{}, {}]). Each hash represent an image with below properties:
    - **link**: String
    - **description**: String
  - **rooms**: Array of hashes (eg: [{}, {}]). Each hash represent an image with below properties:
    - **link**: String
    - **description**: String
  - **site**: Array of hashes (eg: [{}, {}]). Each hash represent an image with below properties:
    - **link**: String
    - **description**: String
- **booking_conditions**: Array of String

### Merging Logic
- **id**: unique - no merge
- **destination_id**: unique - no merge
- **name**: Longest name post trim leading trailing spaces is chosen.
- **location**:
  - For address, city, lat, lng - The first not null value is chosen while merging.
  - For country - Country with 2 characters is given priority (like: SG). If country code not there, then the first not null value is chosen.
- **description**: Description decision is driven by application configuration variable ```merge_description```. If true, descriptions are concatenated else the longest description is chosen.
- **amenities**: Combining from all suppliers and then keeping only unique values for each category, i.e., general and room. Before selecting unique values, removing all the spaces from all values and made lowercase so as the unique operation chose only one for entries like (business center and BusinessCenter).
  For overlapping amenities both in `general` and `room` then -> `general` amenity is given prefernence so keeping only those amenities in `room` which are not in `general`.
- **images**: images for all the categories (`site, amenities, rooms`) from all suppliers are combined and only unique images as per url is kept in each category.
- **booking_conditions**: Resulting booking conditions is an array with only unique booking conditions post trimming leading and trailing spaces from all suppliers.
### Optimisations
- **Data Procurement**
  - We are caching the suppliers hotel's merged data for 24 hours - Cached data is updated after 24 hours next time anyone hits search API call. As per config, if `use_cached_supplier_data` is set to true and cached data is not older than 24 hours, we use cached data and avoid call to fetch and merge data from supplier for every search API call. By default, `use_cached_supplier_data` is set to `true`.
If we want to fetch data freshly from supplier for every search API call, then set `use_cached_supplier_data` to `false`.
- **Data Delivery**
  - Hotel descriptions can be large, and if we try to merge descriptions from all the suppliers they can become too large which can make the response object big inturns heavy load on network. We have added a config variable `merge_descriptions`, If true we concatenate descriptions from all the suppliers else selects the longest one. By default, `merge_descriptions` is set to `true`.
### Configurations
`use_cached_supplier_data` and `merge_descriptions` configurations are present in `config/application.rb`. They can be toggled as per requirement.
### Testing
Tests are written in `/spec/requests/search_hotel_api_spec.rb` directory. To run the specs -
- Login to application's docker container
- Run `rspec`
