from transformers import AutoModelForCausalLM, AutoTokenizer, pipeline
from query import get_relevant_tickets
import torch

import sys

query = sys.argv[1]
relevant_tickets = get_relevant_tickets(query)[:1]

model = "microsoft/Phi-3-mini-4k-instruct"
# model = "microsoft/phi-2"
llm = AutoModelForCausalLM.from_pretrained(
    model,
    device_map="cuda",
    torch_dtype=torch.float16,
    load_in_8bit=True,
    trust_remote_code=True,
    #    attn_implementation="flash_attention"
)

tokenizer = AutoTokenizer.from_pretrained(model)

messages = [{
    "role": "user",
    "content": """
        Instruct: Répond à la demande utilisateur ci-dessous en te basant sur ce qui suit :
        \n
        %s
        \n\n\n
        Maintenant, répond à la demande utilisateur suivante :
        \n
        %s
        Output:
    """ % ("\n\n\n".join([
        "---- Ticket %s ----\n%s" % (t[0], t[1]) for t in relevant_tickets
    ]), query)}]

print(messages)

pipe = pipeline(
    "text-generation",
    model=llm,
    tokenizer=tokenizer
)

output = pipe(
    messages,
    max_new_tokens=128,
    return_full_text=False,
    temperature=0.0,
    do_sample=False,
)
print(output[0]['generated_text'])
