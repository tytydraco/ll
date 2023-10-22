import requests
import json


def scrape():
    take = 20
    skip = 0

    fetched_strains = []

    prev_hash_code = None
    while True:
        req = requests.get('https://consumer-api.leafly.com/api/strain_playlists/v2' +
                           '?enableNewFilters=false' +
                           f'&skip={skip}' +
                           '&strain_playlist=' +
                           f'&take={take}')

        # Break when server refuses.
        if req.status_code != 200:
            break

        # Break when we stop getting new data.
        if req.content.__hash__() == prev_hash_code:
            break
        prev_hash_code = req.content.__hash__()

        _json = json.loads(req.content)

        for rawStrain in _json['hits']['strain']:
            print(rawStrain['name'])
            fetched_strains.append(rawStrain)

        skip += take

        print(f'Fetched: {len(fetched_strains)}')

    with open('results.json', 'w') as f:
        f.write(json.dumps(fetched_strains, indent=2))


if __name__ == '__main__':
    scrape()
