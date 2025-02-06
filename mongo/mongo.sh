show dbs;

use moviedb;

db.dropDatabase();

show collections;

# like find
db.meta.find({Name:/大/})

db.meta.find({Profession:"TS"})

db.meta.find({Age:{$gte:12,$lte:45})

db.movies.find({releaseDate:{$gte:"2022-10-01",$lte:"2023-09-01"})

db.inventory.find( { item: { $not: /^p.*/ } } )

db.inventory.find( {
    $and: [
        { $or: [ { qty: { $lt : 10 } }, { qty : { $gt: 50 } } ] },
        { $or: [ { sale: true }, { price : { $lt : 5 } } ] }
    ]
} )

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

db.movies.aggregate([
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
    $project: {
      _id: 0,
      'movieId': '$_id',
      'movieTitle': '$title',
      'reviewId': '$reviews._id',
      'reviewText': '$reviews.body'
    }
  }
]).pretty();

