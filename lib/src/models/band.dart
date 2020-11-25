class Band {
  String id;
  String name;
  int votes;

  Band({
    this.id,
    this.name,
    this.votes,
  });

  factory Band.fromMap(Map<String, dynamic> objeto) => Band(
        id: objeto.containsKey('id') ? objeto['id'] : 'no-id',
        name: objeto.containsKey('name') ? objeto['name'] : 'no name',
        votes: objeto.containsKey('votes') ? objeto['votes'] : ' no-votes',
      );
}
