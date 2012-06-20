from sdk import qqweibo as qq_sdk
from sdk import weibopy as sina_sdk

method_dict = {'public_timeline':
                   {"name": {"sina": sina_sdk.API.public_timeline,
                             "qq": qq_sdk.API._statuses_public_timeline},
                    "arg_convert": {},
                    "ret_convert": {"sina": {"text": "text"},
                                    "qq": {"text": "text"},}
                   },

                'home_timeline':
                    {"name": {"sina": sina_sdk.API.friends_timeline,
                              "qq": qq_sdk.API._statuses_home_timeline}, 
                     "arg_convert": {}, 
                     "ret_convert": {"sina": {"text": "text"},
                                     "qq": {"text": "text"}},
                    },

                'user_timeline':
                    {"name": {"sina": sina_sdk.API.user_timeline,
                              "qq": qq_sdk.API._statuses_user_timeline},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"text": "text"},
                                     "qq": {"text": "text"}}
                    },
                

                'publish_tweet':
                   {"name": {"sina": sina_sdk.API.update_status,
                             "qq": qq_sdk.API._t_add},
                    "arg_convert": {"sina": {"text": "status"},
                                    "qq": {'text': "content"}},
                    "ret_convert": {"sina": {"message": "text"},
                                    "qq": {"message": "id"}}
                   },

                'comment':
                    {"name": {"sina": sina_sdk.API.comment,
                              "qq": qq_sdk.API._t_comment},
                     "arg_convert": {"sina": {"id": "id",
                                              "text": "comment"},
                                     "qq": {"id": "reid",
                                            "text": "content"}},
                     "ret_convert": {"sina": {"message": "text"},
                                     "qq": {"message": "id"}}
                    },

                'get_status':
                    {"name": {"sina": sina_sdk.API.get_status,
                              "qq": qq_sdk.API._t_show},
                     "arg_convert": {"sina": {"id": "id"},
                                     "qq": {"id": "id"}},
                     "ret_convert": {"sina": {"text": "text",
                                              "screen_name": "author.name",
                                              "uid": "author.id"},
                                     "qq": {"text": "text",
                                            "screen_name": "nick",
                                            "uid": "name"}}
                    },

                'publish_tweet_with_image':
                    {"name": {"sina": sina_sdk.API.upload,
                              "qq": qq_sdk.API._t_add_pic},
                     "arg_convert": {"sina": {"text": "status",
                                              "image_path": "filename"},
                                     "qq": {"text": "content",
                                            "image_path": "filename"}},
                     "ret_convert": {"sina": {"message": "text"},
                                     "qq": {"message": "id"}}
                    },

                'retweet':
                    {"name": {"sina": sina_sdk.API.repost,
                              "qq": qq_sdk.API._t_re_add},
                     "arg_convert": {"sina": {"id": "id",
                                              "text": "status"},
                                     "qq": {"id": "reid",
                                            "text": "content"}},
                     "ret_convert": {"sina": {"message": "text"},
                                     "qq": {"message": "id"}}
                     },

                'get_user':
                    {"name": {"sina": sina_sdk.API.get_user,
                              "qq": qq_sdk.API._user_other_info},
                     "arg_convert": {"sina": {"uid": "id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"screen_name": "screen_name",
                                              "uid": "id",
                                              "follow_count": "friends_count",
                                              "followers_count": "followers_count",
                                              "tweet_count": "statuses_count",
                                              "location": "location",
                                              "gender": "gender"},
                                     "qq": {"screen_name": "nick",
                                            "uid": "name",
                                            "follow_count": "idolnum",
                                            "followers_count": "fansnum",
                                            "tweet_count": "tweetnum",
                                            "location": "location",
                                            "gender": "sex"}}
                    },

                'search_users':
                    {"name": {"sina": sina_sdk.API.search_users,
                              "qq": qq_sdk.API._search_user},
                     "arg_convert": {"sina": {"keyword": "q"},
                                     "qq": {"keyword": "keyword"}},
                     "ret_convert": {"sina": {"screen_name": "name"},
                                     "qq": {"screen_name": "name"}}
                    },
                    
                'following_list':
                    {"name": {"sina": sina_sdk.API.complete_friends_ids_list,
                              "qq": qq_sdk.API.complete_idolist_only_name},
                     "arg_convert": {"sina": {},
                                     "qq": {}},
                     "ret_convert": {"sina": {},
                                     "qq": {}}
                     },
                
                'follower_list':
                    {"name": {"sina": sina_sdk.API.complete_followers_ids_list,
                              "qq": qq_sdk.API.complete_fanslist_only_name},
                     "arg_convert": {"sina": {},
                                     "qq": {}},
                     "ret_convert": {"sina": {},
                                     "qq": {}}
                    },

                'follow':
                    {"name": {"sina": sina_sdk.API.create_friendship,
                              "qq": qq_sdk.API._friends_add},
                     "arg_convert": {"sina": {"target_id": "user_id"},
                                     "qq": {"target_id": "name"}},
                     "ret_convert": {"sina": {"message": "screen_name"},
                                     "qq": {"message": "msg"}}
                    },
                
                'unfollow':
                    {"name": {"sina": sina_sdk.API.destroy_friendship,
                              "qq": qq_sdk.API._friends_del},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"message": "screen_name"},
                                     "qq": {"message": "msg"}}
                    },

                'is_user_following_me':
                    {"name": {"sina": sina_sdk.API.is_user_following_me,
                              "qq": qq_sdk.API.is_user_following_me},
                     "arg_convert": {"sina": {"user_id": "user_id"},
                                     "qq": {"user_id": "user"}},
                     "ret_convert": {"sina": {},
                                     "qq": {}}
                    },
                    
                'is_following_user':
                    {"name": {"sina": sina_sdk.API.is_following_user,
                              "qq": qq_sdk.API.is_following_user},
                     "arg_convert": {"sina": {"user_id": "user_id"},
                                     "qq": {"user_id": "user"}},
                     "ret_convert": {"sina": {},
                                     "qq": {}}
                    },

                'update_profile':
                    {"name": {"sina": sina_sdk.API.update_profile,
                              "qq": qq_sdk.API._user_update},
                     "arg_convert": {"sina": {"screen_name": "name",
                                              "description": "description"},
                                     "qq": {"screen_name": "nick",
                                            "description": "introduction"}},
                    "ret_convert": {"sina": {"message": "screen_name"},
                                    "qq": {"message": "msg"}}
                    },

                'update_profile_image': 
                    {"name": {"sina": sina_sdk.API.update_profile_image,
                              "qq": qq_sdk.API._user_update_head},
                     "arg_convert": {"sina": {"image": "filename"},
                                     "qq": {"image": "filename"}},
                     "ret_convert": {"sina": {"message": "screen_name"},
                                     "qq": {"message": "msg"}}
                    },

               'search_tweet':
                   {"name": {"sina": sina_sdk.API.trends_statuses,
                             "qq": qq_sdk.API._search_t},
                    "arg_convert": {"sina": {"query": "trend_name"},
                                    "qq": {"query": "keyword"}},
                    "ret_convert": {"sina": {"text": "text",
                                             "user_id": "user.id",
                                             "tweet_id": "mid"},
                                    "qq": {"text": "text",
                                           "user_id": "name",
                                           "tweet_id": "id"}}

                    },

                'me':
                    {"name": {"sina": sina_sdk.API.me,
                              "qq": qq_sdk.API.me},
                    "arg_convert": {},
                    "ret_convert": {"sina": {"screen_name": "screen_name",
                                             "local_id": "id",
                                             "followed_count": "followers_count",
                                             "follow_count": "friends_count",
                                             "tweet_count": "statuses_count"},
                                    "qq": {"screen_name": "nick",
                                           "local_id": "name",
                                           "followed_count": 'fansnum',
                                           "follow_count": "idolnum",
                                           "tweet_count": "tweetnum"}}
                    }
               }
