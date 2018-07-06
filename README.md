## Day19_180706

### 레일즈 프로젝트에서 ajax를 구현하기 위해서 다음과 같은 순서로 진행하자

- 모든 동작을 포함하는 js코드를 작성한다
- ajax코드를 작성한다 `$.ajax({})` 
- url을 지정한다
- 해당 url을 *config/routes.rb* 에서 controller#action을 지정한다.
- controller#action을 작성한다
- *app/view/controller_ 어쩌고 *





### 오늘 할 내용

- 영화내용 30개 넣기
  - faker gem 사용

*seeds.rb*

```ruby

genres = ["Horror", "Thriller", "Action", "Drama","Comedy", "Romance", "SF", "Adventure", "Fantasy"]

images = %w( http://img.khan.co.kr/news/2017/10/31/l_2017103101003415200280211.jpg 
             https://t1.daumcdn.net/thumb/R1280x0/?fname=http://t1.daumcdn.net/brunch/service/user/Ji8/image/XYQ6knUsDYi7uTEoOUWrT09K4bs.jpg
             http://imgmovie.naver.com/mdi/mi/0733/73372_P31_161237.jpg
             http://file.thisisgame.com/upload/tboard/user/2016/07/08/20160708061954_5657.jpg
             http://img.danawa.com/images/descFiles/4/402/3401557_1497838111988.jpeg
             https://i.pinimg.com/originals/df/70/70/df70702365aa41e2b6a6b778d1065d2d.jpg
             http://thumb.zumst.com/530x0/
             http://static.news.zumst.com/images/37/2015/04/28/63dd6dd32b8448c9a3b1e2fb495e1244.jpg
             http://img.insight.co.kr/static/2018/05/24/700/k3p442sg6754iibr1hlw.jpg
             http://www.typographyseoul.com/images/newsEdit/15030516593088077_TS.png )

User.create(email: "aa@aa.aa", password: "123123", password_confirmation: "123123")
30.times do
            Movie.create(title: Faker::Movie.quote, 
                        description: Faker::Lorem.paragraph, 
                        genre: genres.sample, 
                        director: Faker::HarryPotter.character, 
                        actor: Faker::FunnyName.two_word_name, 
                        remote_image_path_url: images.sample,
                        user_id: 1)
end
```

`binn02:~/watcha_app (master) $ rake db:reset` 

- hashtag
  - input창에 글자를 한 글자 입력(이벤트)할 때마다(이벤트리스너)
  - server로 해당글자를 검색하는 요청을 보내고
  - 응답으로 날아온 영화제목 리스트를 화면에 보여준다

*index.html.erb*

```ruby
<input type="text" class="form-control movie-title">
<div class="recomm-movie d-flex justify-content-start">

</div>
...  
<script>
    $(document).on('ready', function(){
      $('.movie-title').on('keyup',function(){
        var title = $(this).val();
        $('.recomm-movie').html(`<a>${$(this).val()}</a>`);
        $.ajax({
          url: '/serach_movie',
          data: {
            q: title
          }
        })
      })
    });
  </script>
```

*routes.rb* 

```ruby
 collection do
      get '/search_movie'=> "movies#search_movie"
    end
```

*movie_controller.rb*

```ruby
 before_action :js_authenticate_user!, only: [:like_movie, :create_comment, :destroy_comment, :update_comment]
  before_action :authenticate_user!, except: [:index, :show, :search_movie]
...
  def search_movie
    @movies = Movie.where("title LIKE ?", "#{params[:q]}%")
  end
```

*search_movie*

```ruby
console.log("찾음");
 $('.recomm-movie').html(`
  <% @movies.each do |movie| %>    
 <span class="badge badge-primary"><%= movie.title %></span>&nbsp;&nbsp;
 <%end%>
 `);
```

> &nbsp;&nbsp;`&nbsp;&nbsp;` : 얘는 자동완성검색어 사이에 공백을 주기 위해서
>
> 문제 : 공백일 경우 모든 영화제목이 다 나온다.
>
> 그러니 *movie_controller.rb *에 search_movie에 분기를 주자.

*movie_controller.rb*

```ruby
 def search_movie
    if params[:q].strip.empty? # 완전히 빈 공백일 경우를 위해
      render nothing: true 
      # 아무응답도 해주지 말라 라는 뜻.
    else
    @movies = Movie.where("title LIKE ?", "#{params[:q]}%")
    end
  end
```

> 문자열을 입력후 한개의 문자열 제외하고 전부 지웠을때에는 결과가 남아있다. 그렇기 때문에 keyup할때 모두 지워지는코드를 index의 자바스크립트에 추가해주자

*index.html.erb*

```ruby
 <script>
    $(document).on('ready', function(){
      $('.movie-title').on('keyup',function(){
        $('.recomm-movie').html('');
          
        var title = $(this).val();
        $.ajax({
          url: '/movies/search_movie',
          data: {
            q: title
          }
        })
      })
    });
  </script>
```

> 하지만 지울때마다 넘 깜빡거려서 아주 거슬립니다
>
> 이걸 어떻게 해결할꼬니?
>
> respond_to do 사용
>
> 요청이 오는 방식에 따라 응답을 다르게 주자~ 라는 뜻이래.

*movie_controller.rb*

```ruby
def search_movie
    respond_to do |format|  # 분기 : 서로 다른 자바스크립트 파일을 보내줄경우
      if params[:q].strip.empty?
      format.js {render 'no_content'}
      # 아무응답도 해주지 말라 라는 뜻.
     else
       @movies = Movie.where("title LIKE ?", "#{params[:q]}%")
        format.js {render 'search_movie'}
      end
    end
end
```

> format.html
>
> format.json
>
> 이런 형태로 사용가능합니다.

*index.html.erb*

```ruby
<div class="recomm-movie d-flex justify-content-start row">
```

> 뒤에 row를 주어 끝까지 가지않고 끊어서 다음행으로 넘어갈수있도록 해주자.



- 제목중복, 아이디 중복도 이런 방식으로 진행된다.

  - change는 검색어가 바뀌고 엔터를 쳤을때 결과가 나오도록.

  > ```ruby
  >  <script>
  >     $(document).on('ready', function(){
  >       $('.movie-title').on('change',function(){
  >         $('.recomm-movie').html('');
  >           
  >         var title = $(this).val();
  >         $.ajax({
  >           url: '/movies/search_movie',
  >           data: {
  >             q: title
  >           }
  >         })
  >       })
  >     });
  >   </script>
  > ```
  >
  > 



### Kaminari ( pagination )

https://github.com/kaminari/kaminari

To fetch the 7th page of users (default `per_page` is 25) 

- gem 설치후 `bundle install`
- 한 페이지에 25개씩 표시되도록 *movies_controller.rb*에 설정

```ruby
  def index
    @movies = Movie.page(params[:page])
  end
```

- movie.rb 에서 한 페이지에서 볼수있는 갯수는 8개로 설정.

  ```ruby
   paginates_per 8
  ```

- https://my-second-rails-app-binn02.c9users.io/movies?page=3 으로 3page로 이동가능하다

```console
  Rendering movies/index.html.erb within layouts/application
  Movie Load (0.3ms)  SELECT  "movies".* FROM "movies" LIMIT ? OFFSET ?  [["LIMIT", 8], ["OFFSET", 16]]
  Rendered movies/index.html.erb within layouts/application (4.8ms)
Completed 200 OK in 28ms (Views: 26.6ms | ActiveRecord: 0.3ms)
```

> LIMIT : 한 페이지에 보여주는 갯수
>
> OFFSET : 앞에서 건너뛰는 개수

[controller와 view][https://github.com/kaminari/kaminari#controllers]

*index.html.erb*

```ruby
<%= paginate @movies %>
```

> ### Ajax Links (crazy simple, but works perfectly!)
>
> ```
> <%= paginate @users, remote: true %>
> ```

> ```console
> Started GET "/?page=4" for 222.107.238.15 at 2018-07-06 04:21:25 +0000
> Cannot render console from 222.107.238.15! Allowed networks: 127.0.0.1, ::1, 127.0.0.0/127.255.255.255
> Processing by MoviesController#index as JS
>   Parameters: {"page"=>"4"}
>   Rendering movies/index.html.erb within layouts/application
>   Movie Load (0.3ms)  SELECT  "movies".* FROM "movies" LIMIT ? OFFSET ?  [["LIMIT", 8], ["OFFSET", 24]]
>   Rendered movies/index.html.erb within layouts/application (127.3ms)
> Completed 200 OK in 157ms (Views: 152.0ms | ActiveRecord: 0.3ms)
> 
> ```
>
> 이렇게 응답이 오니까 우리가 이걸 *movies_controller.rb* 에서 분기문으로 처리가능
>
> ```ruby
>    respond_to do |format|
>        format.html
>        format.js
>     end
> ```
>
> 이런식으로 !

근데 pagination이 마음에 안들어서 bootstrap 적용하고 싶을때!

- https://github.com/KamilDzierbicki/bootstrap4-kaminari-views
- *index.html.erb*

```ruby
<%= paginate @movies, theme: 'twitter-bootstrap-4' %>
```

https://getbootstrap.com/docs/4.1/components/carousel/#slides-only



