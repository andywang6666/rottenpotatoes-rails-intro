class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def show_ratings
    @all_ratings = Movie.pluck(:rating).uniq.sort
  end
  
  def with_ratings
    rating_hash = params[:ratings] != nil ? params[:ratings] : (session[:ratings] != nil ? session[:ratings] : Hash[@all_ratings.collect {|rating| [rating, 1]}])
    session[:ratings] = rating_hash
    @rating_filter = rating_hash.keys
    @movies = Movie.where("lower(rating) in (?)", @rating_filter.map(&:downcase))
  end

  def index
    show_ratings
    with_ratings
    if params.include?(:sort)
      session[:sort] = params[:sort]
    end
    if not (params.include?(:sort) and params.include?(:rating))
      flash.keep
      redirect_to movies_path(:sort => session[:sort], :rating => session[:ratings])
    end
    @movies = @movies.order(params[:sort])
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

end
