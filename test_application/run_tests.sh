rm -rf ./tests/__pycache__
#cd ./tests/
export REDIS_SERVER=localhost
poetry run pytest -vv -s
#cd ./../
