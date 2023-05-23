from metapub import PubMedFetcher


class readList(object):
    def __init__(self, list_pmid):
        self.list_pmid = list_pmid

    def readPmids(self):
        with open(self.list_pmid) as input:
            self.pmids = [line.strip() for line in input.readlines()]


if __name__ == "__main__":
    list = readList("../data/pmids.txt")
    list.readPmids()
    pmid_list = list.pmids
    print(pmid_list)
