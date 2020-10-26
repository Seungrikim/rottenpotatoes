class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    #byebug
    @movies = Movie.all
    @all_ratings = Movie.all_ratings
    if params[:ratings]
      @ratings_to_show = params[:ratings].keys
      session[:filtered] = @ratings_to_show
    elsif session[:filtered]
      store = {}
      session[:filtered].each do |rat|
        store['ratings['+ rat + ']'] = 1
      end
      if params[:sort]
        store['sort'] = params[:sort]
      end
      session[:filtered] = nil
      flash.keep
      redirect_to movies_path(store)
    else
      @ratings_to_show = @all_ratings
    end
    @movies = Movie.with_ratings(@ratings_to_show)

    case params[:sort]
    when 'title'
      @movies.order('title ASC')
      @title_class = "bg-warning hilite"
    when 'release_date'
      @movies.order('release_date ASC')
      @release_date_class = "bg-warning hilite"
    end
  end
  
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
