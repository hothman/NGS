from metapub import PubMedFetcher
from tqdm import tqdm
from random import randint
import argparse


class readList(object):
    def __init__(self, list_pmid):
        self.list_pmid = list_pmid

    def readPmids(self):
        with open(self.list_pmid) as input:
            self.pmids = [line.strip() for line in input.readlines()]

    def getYears(self):
        self.years = []
        fetch = PubMedFetcher()
        for pmid in tqdm(self.pmids):
            article = fetch.article_by_pmid(pmid)
            self.years.append(article.year)
        del fetch
        return self.years


class mirroringPubmed(object):
    def __init__(self, years):
        self.years = years

    def _sampleFromList(self, list_of_articles):
        ran = randint(0, 1000)
        return list_of_articles[ran]

    def fetcher(self, negative_pmids, n_samples=2):
        replicated_pmids = []
        fetch = PubMedFetcher()
        for year in tqdm(self.years):
            query = year+"[DP] NOT 'Pharmacogenetics'[Mesh] NOT review[PT]"
            my_hits = fetch.pmids_for_query(query, retmax=1000)
            i = 1
            while i <= n_samples:
                selected = self._sampleFromList(my_hits)
                while selected in negative_pmids:
                    selected = self._sampleFromList(my_hits)
                replicated_pmids.append(selected)
                i += 1
        return replicated_pmids


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Given a list of PMIDs, returns random articles sampled from the same date")
    parser.add_argument("--pmids", help="A file containing a list of pmids")
    parser.add_argument("--output", help="Output file")
    args = parser.parse_args()

    list = readList(args.pmids)
    list.readPmids()
    years_to_replicate = list.getYears()
    pmids_to_replicate = list.pmids
    replicate_years = mirroringPubmed(years_to_replicate)
    replicated_pmids = replicate_years.fetcher(
        negative_pmids=pmids_to_replicate)
    with open(args.output, "w") as output:
        for pmid in replicated_pmids:
            output.write(pmid+"\n")
