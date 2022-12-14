from fastapi.testclient import TestClient
from numpy.testing import assert_almost_equal

from mlapi import __version__
from mlapi.main import app

client = TestClient(app)



def test_predict():
     data = {"text": ["I hate you.", "I love you."]}
     response = client.post(
         "/predict",
         json=data,
     )


     #print(response.json())
     assert response.status_code == 200
     assert type(response.json()["predictions"]) is list
     assert type(response.json()["predictions"][0]) is list
     assert type(response.json()["predictions"][0][0]) is dict
     assert type(response.json()["predictions"][1][0]) is dict
     assert set(response.json()["predictions"][0][0].keys()) == {"label", "score"}
     assert set(response.json()["predictions"][0][1].keys()) == {"label", "score"}
     assert set(response.json()["predictions"][1][0].keys()) == {"label", "score"}
     assert set(response.json()["predictions"][1][1].keys()) == {"label", "score"}
     assert response.json()["predictions"][0][0]["label"] == "NEGATIVE"
     assert response.json()["predictions"][0][1]["label"] == "POSITIVE"
     assert response.json()["predictions"][1][0]["label"] == "NEGATIVE"
     assert response.json()["predictions"][1][1]["label"] == "POSITIVE"
     ##Because we aren't sure the exact numbers after each training we comment the below out.
    #  assert (
    #         assert_almost_equal(
    #             response.json()["predictions"][0][0]["score"], 0.971, decimal=3
    #         )
    #         is None
    #     )
    #  assert (
    #         assert_almost_equal(
    #             response.json()["predictions"][0][1]["score"], 0.028, decimal=3
    #         )
    #         is None
    #     )
    #  assert (
    #         assert_almost_equal(
    #             response.json()["predictions"][1][0]["score"], 0.001, decimal=3
    #         )
    #         is None
    #     )
    #  assert (
    #         assert_almost_equal(
    #             response.json()["predictions"][1][1]["score"], 0.998, decimal=3
    #         )
    #         is None
    #     )

