defmodule MaccleWeb.Cats do
  use Phoenix.Component

  def cat(assigns) do
    ~H"""
    <div class="cat-container">
      <div class="cat">
        <div class="ear ear--left bg-pink border-8 border-surface2 rounded-sm"></div>
        <div class="ear ear--right bg-pink border-8 border-surface2 rounded-sm"></div>
        <div class="face bg-surface2">
          <div class="eye eye--left after:bg-surface2">
            <div class="eye-pupil bg-lavender"></div>
          </div>
          <div class="eye eye--right after:bg-surface2">
            <div class="eye-pupil bg-lavender"></div>
          </div>
          <div class="muzzle bg-pink"></div>
        </div>
      </div>
    </div>

    <style scoped>
      .cat {
        position: relative;
        height: 85px;
        width: 96.05px;
      }

      .ear {
        position: absolute;
        top: -30%;
        height: 60%;
        width: 25%;
      }
      .ear::before, .ear::after {
        content: "";
        position: absolute;
        bottom: 24%;
        height: 10%;
        width: 5%;
        border-radius: 50%;
      }
      .ear::after {
        transform-origin: 50% 100%;
      }

      .ear--left {
        left: -7%;
        border-radius: 70% 30% 0% 0%/100% 100% 0% 0%;
        transform: rotate(-15deg);
      }
      .ear--left::before, .ear--left::after {
        right: 10%;
      }
      .ear--left::after {
        transform: rotate(-45deg);
      }

      .ear--right {
        right: -7%;
        border-radius: 30% 70% 0% 0%/100% 100% 0% 0%;
        transform: rotate(15deg);
      }
      .ear--right::before, .ear--right::after {
        left: 10%;
      }
      .ear--right::after {
        transform: rotate(45deg);
      }

      .face {
        position: absolute;
        height: 100%;
        width: 100%;
        border-radius: 50%;
      }

      .eye {
        position: absolute;
        top: 35%;
        height: 30%;
        width: 31%;
        background: #fff;
        border-radius: 50% 50% 50% 50%/60% 60% 40% 40%;
      }
      .eye::after {
        content: "";
        position: absolute;
        top: 0;
        left: 0;
        height: 0;
        width: 100%;
        border-radius: 0 0 50% 50%/0 0 40% 40%;
        -webkit-animation: blink 4s infinite ease-in;
              animation: blink 4s infinite ease-in;
        }
        @-webkit-keyframes blink {
        0% {
          height: 0;
        }
        90% {
          height: 0;
        }
        92.5% {
          height: 100%;
        }
        95% {
          height: 0;
        }
        97.5% {
          height: 100%;
        }
        100% {
          height: 0;
        }
      }
      @keyframes blink {
        0% {
          height: 0;
        }
        90% {
          height: 0;
        }
        92.5% {
          height: 100%;
        }
        95% {
          height: 0;
        }
        97.5% {
          height: 100%;
        }
        100% {
          height: 0;
        }
      }
      .eye::before {
        content: "";
        position: absolute;
        top: 60%;
        height: 10%;
        width: 15%;
        background: #fff;
        border-radius: 50%;
      }

      .eye--left {
        left: 0;
      }
      .eye--left::before {
        right: -5%;
      }

      .eye--right {
        right: 0;
      }
      .eye--right::before {
        left: -5%;
      }

      .eye-pupil {
        position: absolute;
        top: 25%;
        height: 50%;
        width: 20%;
        border-radius: 50%;
        -webkit-animation: look-around 4s infinite;
              animation: look-around 4s infinite;
      }
      @-webkit-keyframes look-around {
        0% {
          transform: translate(0);
        }
        5% {
          transform: translate(50%, -25%);
        }
        10% {
          transform: translate(50%, -25%);
        }
        15% {
          transform: translate(-100%, -25%);
        }
        20% {
          transform: translate(-100%, -25%);
        }
        25% {
          transform: translate(0, 0);
        }
        100% {
          transform: translate(0, 0);
        }
      }
      @keyframes look-around {
        0% {
          transform: translate(0);
        }
        5% {
          transform: translate(50%, -25%);
        }
        10% {
          transform: translate(50%, -25%);
        }
        15% {
          transform: translate(-100%, -25%);
        }
        20% {
          transform: translate(-100%, -25%);
        }
        25% {
          transform: translate(0, 0);
        }
        100% {
          transform: translate(0, 0);
        }
      }
      .eye--left .eye-pupil {
        right: 30%;
      }
      .eye--right .eye-pupil {
        left: 30%;
      }
      .eye-pupil::after {
        content: "";
        position: absolute;
        top: 30%;
        right: -5%;
        height: 20%;
        width: 35%;
        border-radius: 50%;
        background: #fff;
      }

      .muzzle {
        position: absolute;
        top: 60%;
        left: 50%;
        height: 6%;
        width: 10%;
        transform: translateX(-50%);
        border-radius: 50% 50% 50% 50%/30% 30% 70% 70%;
      }

      .cat-container {
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        background: transparent;
      }
    </style>
    """
  end
end
