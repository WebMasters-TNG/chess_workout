require 'rails_helper'

RSpec.describe PiecesController, type: :controller do
  describe "Action: pieces#update" do

    describe "all pieces" do
      let(:user) { FactoryGirl.create(:user) }
      let(:game) { FactoryGirl.create(:game, :white_player_id => user.id) }

      describe "basic pawn movement" do
        let!(:white_pawn) do
          p = game.pieces.where(:type => "Pawn", :color => "white", :x_position => 1, :y_position => 7).first
          p
        end
        let!(:black_pawn) do
          p = game.pieces.where(:type => "Pawn", :color => "black", :x_position => 1, :y_position => 2).first
          p
        end

        before do
          sign_in user
        end

        it "should allow a 2 vertical space move on the pawn's first turn" do
          put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 5 }, :format => :js
          white_pawn.reload

          expect(white_pawn.y_position).to eq 5
          expect(white_pawn.game.turn).to eq 2
          expect(response).to have_http_status(:success)
        end

        it "should not allow a 2 vertical space move beyond the pawn's first turn" do
          game.update_attributes(:turn => 3)
          game.reload

          put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 4 }, :format => :js
          white_pawn.reload

          expect(white_pawn.y_position).to eq 7
          expect(white_pawn.game.turn).to eq 3
          expect(response).to have_http_status(:unauthorized)
        end

        it "should not allow a greater than 2 vertical space move on the pawn's first turn" do
          put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 4 }, :format => :js
          white_pawn.reload

          expect(white_pawn.x_position).to eq 1
          expect(white_pawn.y_position).to eq 7
          expect(white_pawn.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end

        it "should allow a 1 vertical space move beyond the pawn's first turn" do
          game.update_attributes(:turn => 3)
          game.reload

          put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 6 }, :format => :js
          white_pawn.reload

          expect(white_pawn.y_position).to eq 6
          expect(white_pawn.game.turn).to eq 4
          expect(response).to have_http_status(:success)
        end

        it "should not allow a move when there is a non-capturable piece at the destination site" do
          # The white pawn begins at [1, 3], on turn 3:
          game.update_attributes(:turn => 3)
          game.reload
          white_pawn.update_attributes(:y_position => 3)
          white_pawn.reload

          # A black pawn will be at [1, 2]:
          put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 2 }, :format => :js
          white_pawn.reload

          expect(white_pawn.y_position).to eq 3
          expect(white_pawn.game.turn).to eq 3
          expect(response).to have_http_status(:unauthorized)
        end

        it "should not allow a move when a non-capturable piece is blocking its path" do
          # The white pawn begins at [1, 3], on turn 3:
          game.update_attributes(:turn => 3)
          game.reload
          white_pawn.update_attributes(:y_position => 3)
          white_pawn.reload

          # Remove the black rook at [1, 1]:
          black_rook = game.pieces.where(:type => "Rook", :color => "black", :x_position => 1, :y_position => 1).first.destroy
          expect(game.pieces.where(:type => "Rook", :color => "black").count).to eq 1

          # Try moving the white pawn to the now empty square of [1, 1].  A black pawn will be in its path at [1, 2]:
          put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 1 }, :format => :js
          white_pawn.reload

          expect(white_pawn.y_position).to eq 3
          expect(white_pawn.game.turn).to eq 3
          expect(response).to have_http_status(:unauthorized)
        end

        it "should allow a diagonal move with a capturable piece on the destination square" do
          # The black pawn begins at [2, 6], on turn 7:
          game.update_attributes(:turn => 7)
          game.reload
          black_pawn.update_attributes(:x_position => 2, :y_position => 6)
          black_pawn.reload

          # Capture the black pawn:
          put :update, :id => white_pawn.id, :piece => { :x_position => 2, :y_position => 6 }, :format => :js
          white_pawn.reload

          expect(white_pawn.x_position).to eq 2
          expect(white_pawn.y_position).to eq 6
          expect(white_pawn.game.turn).to eq 8
          expect(response).to have_http_status(:success)
        end

        it "should not allow a diagonal move without a capturable piece on the destination square" do
          put :update, :id => white_pawn.id, :piece => { :x_position => 2, :y_position => 6 }, :format => :js
          white_pawn.reload

          expect(white_pawn.x_position).to eq 1
          expect(white_pawn.y_position).to eq 7
          expect(white_pawn.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end

        it "should not allow a non-capturing move when the destination square has an allied piece" do
          white_rook = game.pieces.where(:type => "Rook", :color => "white", :x_position => 1).first
          white_rook.update_attributes(:y_position => 6)
          white_rook.reload

          # Try moving the first white pawn onto the white rook at [1, 6]:
          put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 6 }, :format => :js
          white_pawn.reload

          expect(white_pawn.y_position).to eq 7
          expect(white_pawn.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end

        it "should not allow a capturing move when the destination square has an allied piece" do
          white_rook = game.pieces.where(:type => "Rook", :color => "white", :x_position => 1).first
          white_rook.update_attributes(:x_position => 2, :y_position => 6)
          white_rook.reload

          # Try moving the first white pawn to capture the white rook at [2, 6]:
          put :update, :id => white_pawn.id, :piece => { :x_position => 2, :y_position => 6 }, :format => :js
          white_pawn.reload

          expect(white_pawn.y_position).to eq 7
          expect(white_pawn.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end
      end

      describe "basic rook movement" do
        let!(:white_rook) do
          p = game.pieces.where(:type => "Rook", :color => "white", :x_position => 1).first
          p
        end

        before do
          sign_in user
        end

        it "should allow a valid non-capturing horizontal move" do
          # The white rook begins at [2, 4]
          white_rook.update_attributes(:x_position => 2, :y_position => 4)
          white_rook.reload

          # Move a white rook 3 horizontal spaces to the right on its first turn:
          put :update, :id => white_rook.id, :piece => { :x_position => 5, :y_position => 4 }, :format => :js
          white_rook.reload

          expect(white_rook.x_position).to eq 5
          expect(white_rook.y_position).to eq 4
          expect(white_rook.game.turn).to eq 2
          expect(response).to have_http_status(:success)
        end

        it "should allow a valid non-capturing vertical move" do
          # The white rook begins at [2, 4]
          white_rook.update_attributes(:x_position => 2, :y_position => 4)
          white_rook.reload

          # Move a white rook 3 horizontal spaces to the right on its first turn:
          put :update, :id => white_rook.id, :piece => { :x_position => 2, :y_position => 6 }, :format => :js
          white_rook.reload

          expect(white_rook.x_position).to eq 2
          expect(white_rook.y_position).to eq 6
          expect(white_rook.game.turn).to eq 2
          expect(response).to have_http_status(:success)
        end

        it "should allow a valid capturing move" do
          # The white rook begins at [1, 4]:
          white_rook.update_attributes(:y_position => 4)
          white_rook.reload

          # Capture the black pawn at [1, 2]
          put :update, :id => white_rook.id, :piece => { :x_position => 1, :y_position => 2 }, :format => :js
          white_rook.reload

          expect(white_rook.x_position).to eq 1
          expect(white_rook.y_position).to eq 2
          expect(white_rook.game.turn).to eq 2
          expect(response).to have_http_status(:success)
        end

        it "should not allow diagonal rook moves" do
          # The white rook begins at [1, 5]
          white_rook.update_attributes(:y_position => 5)
          white_rook.reload

          # Try moving diagonally:
          put :update, :id => white_rook.id, :piece => { :x_position => 3, :y_position => 3 }, :format => :js
          white_rook.reload

          expect(white_rook.x_position).to eq 1
          expect(white_rook.y_position).to eq 5
          expect(white_rook.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end


        it "should not allow a move when an allied piece is blocking its path" do
          # The white rook begins at [1, 8].  Try moving forward two squares, past the white pawn at [1, 7]:
          put :update, :id => white_rook.id, :piece => { :x_position => 1, :y_position => 6 }, :format => :js
          white_rook.reload

          expect(white_rook.y_position).to eq 8
          expect(white_rook.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end

        it "should not allow a move when the destination square has an allied piece" do
          # Try moving onto the white pawn at [1, 7]:
          put :update, :id => white_rook.id, :piece => { :x_position => 1, :y_position => 7 }, :format => :js
          white_rook.reload

          expect(white_rook.y_position).to eq 8
          expect(white_rook.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end
      end

      describe "basic knight movement" do
        let!(:white_knight) do
          p = game.pieces.where(:type => "Knight", :color => "white", :x_position => 2).first
          p
        end

        before do
          sign_in user
        end

        it "should allow a valid non-capturing L-shaped move" do
          # White knight starts at [2, 8].
          put :update, :id => white_knight.id, :piece => { :x_position => 3, :y_position => 6 }, :format => :js
          white_knight.reload

          expect(white_knight.x_position).to eq 3
          expect(white_knight.y_position).to eq 6
          expect(white_knight.game.turn).to eq 2
          expect(response).to have_http_status(:success)
        end

        it "should allow a valid L-shaped capturing move" do
          # Modify the starting position to be [2, 4]:
          white_knight.update_attributes(:x_position => 2, :y_position => 4)
          white_knight.reload

          # Capture the black pawn at [3, 2]:
          put :update, :id => white_knight.id, :piece => { :x_position => 3, :y_position => 2 }, :format => :js
          white_knight.reload

          expect(white_knight.x_position).to eq 3
          expect(white_knight.y_position).to eq 2
          expect(white_knight.game.turn).to eq 2
          expect(response).to have_http_status(:success)
        end

        it "should not allow a vertical move" do
          white_knight.update_attributes(:x_position => 2, :y_position => 6)
          white_knight.reload

          put :update, :id => white_knight.id, :piece => { :x_position => 2, :y_position => 4 }, :format => :js
          white_knight.reload

          expect(white_knight.x_position).to eq 2
          expect(white_knight.y_position).to eq 6
          expect(white_knight.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end

        it "should not allow a horizontal move" do
          white_knight.update_attributes(:x_position => 2, :y_position => 6)
          white_knight.reload

          put :update, :id => white_knight.id, :piece => { :x_position => 4, :y_position => 6 }, :format => :js
          white_knight.reload

          expect(white_knight.x_position).to eq 2
          expect(white_knight.y_position).to eq 6
          expect(white_knight.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end

        it "should not allow a diagonal move" do
          white_knight.update_attributes(:x_position => 2, :y_position => 6)
          white_knight.reload

          put :update, :id => white_knight.id, :piece => { :x_position => 3, :y_position => 5 }, :format => :js
          white_knight.reload

          expect(white_knight.x_position).to eq 2
          expect(white_knight.y_position).to eq 6
          expect(white_knight.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end

        # *************************
        # *************************
        # The failing test below has been confirmed to occur in the browser.  Right now the knight can capture an allied piece.
        # *************************
        # *************************
        it "should not allow a move when the destination square has an allied piece" do
          put :update, :id => white_knight.id, :piece => { :x_position => 4, :y_position => 7 }, :format => :js
          white_knight.reload

          expect(white_knight.x_position).to eq 2
          expect(white_knight.y_position).to eq 8
          expect(white_knight.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end
      end

      describe "basic bishop movement" do
        let!(:white_bishop) do
          p = game.pieces.where(:type => "Bishop", :color => "white", :x_position => 3).first
          p
        end

        before do
          sign_in user
        end

        it "should allow a valid non-capturing diagonal move" do
          # Place the white bishop at [3, 6]:
          white_bishop.update_attributes(:y_position => 6)
          white_bishop.reload

          put :update, :id => white_bishop.id, :piece => { :x_position => 5, :y_position => 4 }, :format => :js
          white_bishop.reload

          expect(white_bishop.x_position).to eq 5
          expect(white_bishop.y_position).to eq 4
          expect(white_bishop.game.turn).to eq 2
          expect(response).to have_http_status(:success)
        end

        it "should allow a valid capturing diagonal move" do
          # Place the white bishop at [3, 6]:
          white_bishop.update_attributes(:y_position => 6)
          white_bishop.reload

          # Capture the black pawn at [7, 2]:
          put :update, :id => white_bishop.id, :piece => { :x_position => 7, :y_position => 2 }, :format => :js
          white_bishop.reload

          expect(white_bishop.x_position).to eq 7
          expect(white_bishop.y_position).to eq 2
          expect(white_bishop.game.turn).to eq 2
          expect(response).to have_http_status(:success)
        end

        it "should not allow a vertical move" do
          # Place the white bishop at [3, 6]:
          white_bishop.update_attributes(:y_position => 6)
          white_bishop.reload

          # Try moving to [3, 4]:
          put :update, :id => white_bishop.id, :piece => { :x_position => 3, :y_position => 4 }, :format => :js
          white_bishop.reload

          expect(white_bishop.y_position).to eq 6
          expect(white_bishop.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end

        it "should not allow a horizontal move" do
          # Place the white bishop at [3, 6]:
          white_bishop.update_attributes(:y_position => 6)
          white_bishop.reload

          # Try moving to [5, 6]:
          put :update, :id => white_bishop.id, :piece => { :x_position => 5, :y_position => 6 }, :format => :js
          white_bishop.reload

          expect(white_bishop.x_position).to eq 3
          expect(white_bishop.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end

        it "should not allow a diagonal move when blocked by an allied piece" do
          # Try moving from [3, 8] to [5, 6]:
          put :update, :id => white_bishop.id, :piece => { :x_position => 5, :y_position => 6 }, :format => :js
          white_bishop.reload

          expect(white_bishop.x_position).to eq 3
          expect(white_bishop.y_position).to eq 8
          expect(white_bishop.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end

        it "should not allow a diagonal move when the destination square has an allied piece" do
          # Try moving from [3, 8] to [4, 7]:
          put :update, :id => white_bishop.id, :piece => { :x_position => 4, :y_position => 7 }, :format => :js
          white_bishop.reload

          expect(white_bishop.x_position).to eq 3
          expect(white_bishop.y_position).to eq 8
          expect(white_bishop.game.turn).to eq 1
          expect(response).to have_http_status(:unauthorized)
        end
      end

      describe "basic queen movement" do
        let!(:white_queen) do
          p = game.pieces.where(:type => "Queen", :color => "white", :x_position => 4).first
          p
        end

        before do
          sign_in user
        end

        describe "diagonal moves" do
          it "should allow a valid non-capturing multi-square diagonal move" do
            white_queen.update_attributes(:y_position => 6)
            white_queen.reload

            # Try moving from [4, 6] to [2, 4]:
            put :update, :id => white_queen.id, :piece => { :x_position => 2, :y_position => 4 }, :format => :js
            white_queen.reload

            expect(white_queen.x_position).to eq 2
            expect(white_queen.y_position).to eq 4
            expect(white_queen.game.turn).to eq 2
            expect(response).to have_http_status(:success)
          end

          it "should allow a valid capturing multi-square diagonal move" do
            white_queen.update_attributes(:y_position => 6)
            white_queen.reload

            # Capture the black pawn at [8, 2]:
            put :update, :id => white_queen.id, :piece => { :x_position => 8, :y_position => 2 }, :format => :js
            white_queen.reload

            expect(white_queen.x_position).to eq 8
            expect(white_queen.y_position).to eq 2
            expect(white_queen.game.turn).to eq 2
            expect(response).to have_http_status(:success)
          end

          it "should not allow a diagonal move when blocked by an allied piece" do
            # The white pawn at [5, 7] should block an attempted move to [6, 6]:
            put :update, :id => white_queen.id, :piece => { :x_position => 6, :y_position => 6 }, :format => :js
            white_queen.reload

            expect(white_queen.x_position).to eq 4
            expect(white_queen.y_position).to eq 8
            expect(white_queen.game.turn).to eq 1
            expect(response).to have_http_status(:unauthorized)
          end

          it "should not allow a diagonal move when the destination square has an allied piece" do
            # The white pawn at [5, 7] should block an attempted move to [5, 7]:
            put :update, :id => white_queen.id, :piece => { :x_position => 5, :y_position => 7 }, :format => :js
            white_queen.reload

            expect(white_queen.x_position).to eq 4
            expect(white_queen.y_position).to eq 8
            expect(white_queen.game.turn).to eq 1
            expect(response).to have_http_status(:unauthorized)
          end
        end

        describe "vertical moves" do
          it "should allow a valid non-capturing multi-square vertical move" do
            white_queen.update_attributes(:y_position => 6)
            white_queen.reload

            # Try moving from [4, 6] to [4, 4]:
            put :update, :id => white_queen.id, :piece => { :x_position => 4, :y_position => 4 }, :format => :js
            white_queen.reload

            expect(white_queen.y_position).to eq 4
            expect(white_queen.game.turn).to eq 2
            expect(response).to have_http_status(:success)
          end

          it "should allow a valid capturing multi-square vertical move" do

          end

          it "should not allow a vertical move when blocked by an allied piece" do
            # The white pawn at [4, 7] should block a move from [4, 8] to [4, 6]:
            put :update, :id => white_queen.id, :piece => { :x_position => 4, :y_position => 6 }, :format => :js
            white_queen.reload

            expect(white_queen.y_position).to eq 8
            expect(white_queen.game.turn).to eq 1
            expect(response).to have_http_status(:unauthorized)
          end

          it "should not allow a vertical move when the destination square has an allied piece" do
            # The white pawn at [4, 7] should block a move from [4, 8] to [4, 7]:
            put :update, :id => white_queen.id, :piece => { :x_position => 4, :y_position => 7 }, :format => :js
            white_queen.reload

            expect(white_queen.y_position).to eq 8
            expect(white_queen.game.turn).to eq 1
            expect(response).to have_http_status(:unauthorized)
          end
        end

        describe "horizontal moves" do
          it "should allow a valid non-capturing multi-square horizontal move" do
            white_queen.update_attributes(:y_position => 6)
            white_queen.reload

            # Try moving from [4, 6] to [6, 6]:
            put :update, :id => white_queen.id, :piece => { :x_position => 6, :y_position => 6 }, :format => :js
            white_queen.reload

            expect(white_queen.x_position).to eq 6
            expect(white_queen.game.turn).to eq 2
            expect(response).to have_http_status(:success)
          end

          it "should allow a valid capturing multi-square horizontal move" do

          end

          it "should not allow a horizontal move when blocked by an allied piece" do
            # The white king at [5, 8] should block a move from [4, 8] to [6, 8]:
            put :update, :id => white_queen.id, :piece => { :x_position => 6, :y_position => 8 }, :format => :js
            white_queen.reload

            expect(white_queen.x_position).to eq 4
            expect(white_queen.game.turn).to eq 1
            expect(response).to have_http_status(:unauthorized)
          end

          it "should not allow a horizontal move when the destination square has an allied piece" do
            # The white king at [5, 8] should block a move from [4, 8] to [5, 8]:
            put :update, :id => white_queen.id, :piece => { :x_position => 5, :y_position => 8 }, :format => :js
            white_queen.reload

            expect(white_queen.x_position).to eq 4
            expect(white_queen.game.turn).to eq 1
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      describe "basic king movement" do
        let!(:white_king) do
          p = game.pieces.where(:type => "King", :color => "white", :x_position => 5).first
          p
        end

        before do
          sign_in user
        end

        describe "diagonal moves" do
          it "should allow a valid non-capturing diagonal move" do

          end

          it "should allow a valid capturing diagonal move" do

          end

          it "should not allow a multi-square diagonal move" do

          end

          it "should not allow a diagonal move when blocked by an allied piece" do

          end

          it "should not allow a diagonal move when the destination square has an allied piece" do

          end
        end

        describe "vertical moves" do
          it "should allow a valid non-capturing single vertical move" do

          end

          it "should allow a valid capturing vertical move" do

          end

          it "should not allow a multi-square vertical move" do

          end

          it "should not allow a vertical move when blocked by an allied piece" do

          end

          it "should not allow a vertical move when the destination square has an allied piece" do

          end
        end

        describe "horizontal moves" do
          it "should allow a valid non-capturing horizontal move" do

          end

          it "should allow a valid capturing horizontal move" do

          end

          it "should not allow a multi-square horizontal move" do

          end

          it "should not allow a horizontal move when blocked by an allied piece" do

          end

          it "should not allow a horizontal move when the destination square has an allied piece" do

          end
        end
      end

      describe "en passant capture of the black pawn" do
        let(:user2) { FactoryGirl.create(:user) }
        let(:game) { FactoryGirl.create(:game, :white_player_id => user.id, :black_player_id => user2.id) }
        let!(:white_pawn) do
          p = game.pieces.where(:type => "Pawn", :color => "white").first
          p.update_attributes(:x_position => 2, :y_position => 4)
          p
        end
        let!(:black_pawn) do
          p = game.pieces.where(:type => "Pawn", :color => "black").first
          p.update_attributes(:x_position => 1, :y_position => 4)
          p
        end

        before do
          sign_in user
        end

        it "should recognize a valid en passant move by the white pawn" do
          white_pawn_start_x = white_pawn.x_position
          white_pawn_start_y = white_pawn.y_position

          # The white pawn makes an en passant capture on the black pawn, moving from [2, 4] to [1, 3] (assume en passant is valid prior to confirming below)
          put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 3 }, :format => :js
          white_pawn.reload

          # Check that the white pawn can execute the en_passant move
          expect(white_pawn.en_passant?(white_pawn_start_x, white_pawn_start_y, white_pawn.x_position, white_pawn.y_position)).to eq true
          expect(white_pawn.x_position).to eq 1
          expect(white_pawn.y_position).to eq 3
          expect(white_pawn.game.turn).to eq 2
          expect(response).to have_http_status(:success)
        end

        it "should not recognize an invalid en passant move by the white pawn" do
          white_pawn_start_x = white_pawn.x_position
          white_pawn_start_y = white_pawn.y_position

          put :update, :id => white_pawn.id, :piece => { :x_position => 3, :y_position => 3 }, :format => :js
          white_pawn.reload

          expect(white_pawn.en_passant?(white_pawn_start_x, white_pawn_start_y, white_pawn.x_position, white_pawn.y_position)).to eq nil
          expect(white_pawn.x_position).to eq 2
          expect(white_pawn.y_position).to eq 4
          expect(white_pawn.game.turn).to eq 1
        end
      end

      describe "en passant capture of the white pawn" do
        let(:user2) { FactoryGirl.create(:user) }
        let(:game) { FactoryGirl.create(:game, :white_player_id => user.id, :black_player_id => user2.id, :turn => 2) }
        let!(:white_pawn) do
          p = game.pieces.where(:type => "Pawn", :color => "white").first
          p.update_attributes(:x_position => 2, :y_position => 5)
          p.moves = []
          p
        end
        let!(:black_pawn) do
          p = game.pieces.where(:type => "Pawn", :color => "black").first
          p.moves = []
          p.update_attributes(:x_position => 1, :y_position => 5)
          p
        end
        let(:move) { FactoryGirl.create(:move, :game_id => game.id, :piece_id => black_pawn.id, :move_count => 0) }

        before do
          sign_in user2
        end

        it "should recognize a valid en passant move by the black pawn" do
          black_pawn_start_x = black_pawn.x_position
          black_pawn_start_y = black_pawn.y_position

          put :update, :id => black_pawn.id, :piece => { :x_position => 2, :y_position => 6 }, :format => :js
          black_pawn.reload

          expect(black_pawn.en_passant?(black_pawn_start_x, black_pawn_start_y, black_pawn.x_position, black_pawn.y_position)).to eq true
          expect(black_pawn.x_position).to eq 2
          expect(black_pawn.y_position).to eq 6
          expect(black_pawn.game.turn).to eq 3
        end

        it "should not recognize an invalid en passant move by the black pawn" do
          black_pawn_start_x = black_pawn.x_position
          black_pawn_start_y = black_pawn.y_position

          put :update, :id => black_pawn.id, :piece => { :x_position => 2, :y_position => 7 }, :format => :js
          black_pawn.reload

          expect(black_pawn.en_passant?(black_pawn_start_x, black_pawn_start_y, black_pawn.x_position, black_pawn.y_position)).to eq nil
          expect(black_pawn.x_position).to eq 1
          expect(black_pawn.y_position).to eq 5
          expect(black_pawn.game.turn).to eq 2
        end
      end

      describe "pawn promotion" do
        let!(:white_pawn) do
          p = game.pieces.where(:type => "Pawn", :color => "white", :x_position => 1).first
          p.update_attributes(:y_position => 2)
          p
        end
        let(:black_pawn) do
          # Remove the black pawn at [1, 2]:
          p = game.pieces.where(:type => "Pawn", :color => "black", :x_position => 1).first
          p.update_attributes(:x_position => 5, :y_position => 5)
          p
        end
        let(:black_rook) do
          # Remove the black rook at [1, 1]:
          p = game.pieces.where(:type => "Rook", :color => "black", :x_position => 1).first
          p.update_attributes(:x_position => 6, :y_position => 5)
          p
        end

        before do
          sign_in user
        end

        it "should allow promotion to queen" do
          put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 1 }, :format => :js
          white_pawn.reload

          binding.pry
          # *** IS THERE A ROOK STILL HERE WHEN THE TEST RUNS?  IS THIS PAWN BLOCKED? ***
          # *** Just checked in the console.  There isn't any piece there.  The update isn't going through for some other reason. ***
          # *** Could en passant be screwing with this, given that there is a black pawn beside this white pawn? ***
          expect(white_pawn.y_position).to eq 1
          expect(white_pawn.type).to eq "Queen"
        end

        it "should allow promotion to knight" do
          put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 1 }, :format => :js
          white_pawn.reload

          expect(white_pawn.y_position).to eq 1
          expect(white_pawn.type).to eq "Knight"
        end

        it "should allow promotion to rook" do
          put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 1 }, :format => :js
          white_pawn.reload

          expect(white_pawn.y_position).to eq 1
          expect(white_pawn.type).to eq "Rook"
        end
      end


      it "should recognize castling as a valid move" do
        sign_in user
      end


      it "should recognize a valid checkmate move" do
        sign_in user
      end
    end
  end
end
