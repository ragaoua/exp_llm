from sentence_transformers import SentenceTransformer


class EmbeddingModel:

    def __init__(self):

        self.model = SentenceTransformer(
            "paraphrase-MiniLM-L3-v2",
            # device="mps"
            # device="cuda"
        )

    def encode(self, text):
        return self.model.encode(text)
