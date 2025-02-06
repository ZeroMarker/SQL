select *
from moviedb.movies;


db.movies.aggregate([
  {
    $match: { title: /the/ }
  },
  {
    $lookup: {
      from: 'reviews',
      localField: 'reviewIds',
      foreignField: '_id',
      as: 'reviews'
    }
  },
  {
    $unwind: '$reviews'
  },
  {
    $group: {
      _id: '$_id',
      title: { $first: '$title' },
      reviews: { $push: '$reviews' }
    }
  }
])
